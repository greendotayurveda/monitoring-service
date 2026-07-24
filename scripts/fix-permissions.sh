#!/usr/bin/env bash
# Fix bind-mount ownership/permissions so Prometheus/Loki/Grafana can write.
# Uses both chown and chmod so it still works when Docker userns-remap is enabled.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

mkdir -p \
  data/prometheus \
  data/loki/chunks \
  data/loki/rules \
  data/loki/tsdb-index \
  data/loki/tsdb-cache \
  data/loki/compactor \
  data/loki/rules-temp \
  data/grafana \
  data/alertmanager \
  data/uptime-kuma \
  backups

echo "Setting ownership (best effort)..."
sudo chown -R 65534:65534 data/prometheus data/alertmanager || true
sudo chown -R 10001:10001 data/loki || true
sudo chown -R 472:472 data/grafana || true

echo "Opening write access on data dirs (required for some Docker userns setups)..."
sudo chmod -R a+rwX \
  data/prometheus \
  data/loki \
  data/grafana \
  data/alertmanager \
  data/uptime-kuma

# Also chown from inside a container in case host UID mapping differs
if command -v docker >/dev/null 2>&1; then
  echo "Applying ownership via busybox containers..."
  docker run --rm -v "${ROOT_DIR}/data/prometheus:/data" busybox:1.36 chown -R 65534:65534 /data || true
  docker run --rm -v "${ROOT_DIR}/data/alertmanager:/data" busybox:1.36 chown -R 65534:65534 /data || true
  docker run --rm -v "${ROOT_DIR}/data/loki:/data" busybox:1.36 chown -R 10001:10001 /data || true
  docker run --rm -v "${ROOT_DIR}/data/grafana:/data" busybox:1.36 chown -R 472:472 /data || true
fi

echo "Permissions fixed."
ls -lan data/
