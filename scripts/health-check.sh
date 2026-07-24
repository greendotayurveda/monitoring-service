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
# health checks use loopback unless bind is explicitly something else reachable
CHECK_HOST="127.0.0.1"
GRAFANA_PORT="${GRAFANA_PORT:-3000}"
UPTIME_KUMA_PORT="${UPTIME_KUMA_PORT:-3002}"
PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
ALERTMANAGER_PORT="${ALERTMANAGER_PORT:-9093}"
LOKI_PORT="${LOKI_PORT:-3100}"
CADVISOR_PORT="${CADVISOR_PORT:-8080}"
NODE_EXPORTER_PORT="${NODE_EXPORTER_PORT:-9100}"

echo "Compose service status:"
docker compose ps

echo
echo "Endpoint checks (${CHECK_HOST}; bind=${BIND_ADDRESS}):"
fail=0
check() {
  local name="$1" url="$2"
  if curl -fsS --max-time 5 "$url" >/dev/null; then
    echo "OK  ${name} (${url})"
  else
    echo "FAIL ${name} (${url})"
    fail=1
  fi
}

check prometheus "http://${CHECK_HOST}:${PROMETHEUS_PORT}/-/healthy"
check alertmanager "http://${CHECK_HOST}:${ALERTMANAGER_PORT}/-/healthy"
check loki "http://${CHECK_HOST}:${LOKI_PORT}/ready"
check grafana "http://${CHECK_HOST}:${GRAFANA_PORT}/api/health"
check cadvisor "http://${CHECK_HOST}:${CADVISOR_PORT}/healthz"
check node-exporter "http://${CHECK_HOST}:${NODE_EXPORTER_PORT}/metrics"
check uptime-kuma "http://${CHECK_HOST}:${UPTIME_KUMA_PORT}"

exit "${fail}"
