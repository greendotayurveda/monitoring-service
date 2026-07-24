#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "Compose service status:"
docker compose ps

echo
echo "Endpoint checks (localhost):"
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

check prometheus "http://127.0.0.1:9090/-/healthy"
check alertmanager "http://127.0.0.1:9093/-/healthy"
check loki "http://127.0.0.1:3100/ready"
check grafana "http://127.0.0.1:3000/api/health"
check cadvisor "http://127.0.0.1:8080/healthz"
check node-exporter "http://127.0.0.1:9100/metrics"
check uptime-kuma "http://127.0.0.1:3001"

exit "${fail}"
