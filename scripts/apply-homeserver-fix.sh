#!/usr/bin/env bash
# One-shot recovery for port conflicts + permission crash-loops on the homeserver.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

chmod +x scripts/*.sh

echo "==> Fixing data permissions"
./scripts/fix-permissions.sh

if [[ -f .env ]]; then
  # Ensure conflict-safe ports exist in .env (append if missing)
  grep -q '^GRAFANA_PORT=' .env || echo 'GRAFANA_PORT=3010' >> .env
  grep -q '^UPTIME_KUMA_PORT=' .env || echo 'UPTIME_KUMA_PORT=3002' >> .env
  grep -q '^GF_SERVER_ROOT_URL=' .env || echo 'GF_SERVER_ROOT_URL=http://127.0.0.1:3010' >> .env
else
  cp .env.example .env
  echo "Created .env from .env.example — set GF_SECURITY_ADMIN_PASSWORD before production use."
fi

echo "==> Recreating stack"
docker compose down
docker compose up -d

echo "==> Waiting a few seconds for health"
sleep 5
./scripts/health-check.sh || true

echo
echo "If anything still fails, inspect logs:"
echo "  docker logs --tail 100 ms-prometheus"
echo "  docker logs --tail 100 ms-loki"
echo "  docker logs --tail 100 ms-grafana"
echo "  docker logs --tail 100 ms-cadvisor"
