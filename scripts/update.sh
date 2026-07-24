#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE="${1:-}"

cd "${ROOT_DIR}"

if [[ -z "${SERVICE}" ]]; then
  echo "Usage: $0 <service-name>"
  echo "Example: $0 grafana"
  echo "Available: prometheus node-exporter cadvisor loki promtail grafana alertmanager uptime-kuma"
  exit 1
fi

echo "Backing up before update..."
"${ROOT_DIR}/scripts/backup.sh"

echo "Pulling image for ${SERVICE}..."
docker compose pull "${SERVICE}"

echo "Recreating ${SERVICE}..."
docker compose up -d --no-deps "${SERVICE}"

echo "Health check..."
"${ROOT_DIR}/scripts/health-check.sh"

echo "Update of ${SERVICE} complete."
