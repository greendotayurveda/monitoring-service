#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

BIND_ADDRESS="${BIND_ADDRESS:-127.0.0.1}"
CHECK_HOST="127.0.0.1"
GRAFANA_PORT="${GRAFANA_PORT:-3010}"
UPTIME_KUMA_PORT="${UPTIME_KUMA_PORT:-3002}"
PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
ALERTMANAGER_PORT="${ALERTMANAGER_PORT:-9093}"

echo "Compose service status:"
docker compose ps

echo
echo "Container running checks (ms-* names):"
fail=0
require_running() {
  local name="$1"
  local status
  status="$(docker inspect -f '{{.State.Status}}' "${name}" 2>/dev/null || echo missing)"
  if [[ "${status}" == "running" ]]; then
    echo "OK  ${name} is running"
  else
    echo "FAIL ${name} status=${status}"
    fail=1
  fi
}

require_running ms-prometheus
require_running ms-node-exporter
require_running ms-cadvisor
require_running ms-loki
require_running ms-promtail
require_running ms-grafana
require_running ms-alertmanager
require_running ms-uptime-kuma

echo
echo "Published endpoint checks (${CHECK_HOST}; bind=${BIND_ADDRESS}):"
check_http() {
  local name="$1" url="$2"
  if curl -fsS --max-time 5 "$url" >/dev/null; then
    echo "OK  ${name} (${url})"
  else
    echo "FAIL ${name} (${url})"
    fail=1
  fi
}

check_http prometheus "http://${CHECK_HOST}:${PROMETHEUS_PORT}/-/healthy"
check_http alertmanager "http://${CHECK_HOST}:${ALERTMANAGER_PORT}/-/healthy"
check_http grafana "http://${CHECK_HOST}:${GRAFANA_PORT}/api/health"
check_http uptime-kuma "http://${CHECK_HOST}:${UPTIME_KUMA_PORT}"

echo
echo "Internal-only services (via docker exec):"
if docker exec ms-loki wget -qO- http://localhost:3100/ready >/dev/null 2>&1; then
  echo "OK  loki ready (internal)"
else
  echo "FAIL loki ready (internal)"
  fail=1
fi
if docker exec ms-cadvisor wget -qO- http://localhost:8080/healthz >/dev/null 2>&1 \
  || docker exec ms-cadvisor wget -qO- http://localhost:8080/containers/ >/dev/null 2>&1; then
  echo "OK  cadvisor (internal)"
else
  echo "FAIL cadvisor (internal)"
  fail=1
fi
if docker exec ms-node-exporter wget -qO- http://localhost:9100/metrics >/dev/null 2>&1; then
  echo "OK  node-exporter (internal)"
else
  # node-exporter image may lack wget; try from prometheus container
  if docker exec ms-prometheus wget -qO- http://node-exporter:9100/metrics >/dev/null 2>&1; then
    echo "OK  node-exporter (via prometheus network)"
  else
    echo "FAIL node-exporter scrape"
    fail=1
  fi
fi

exit "${fail}"
