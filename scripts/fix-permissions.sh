#!/usr/bin/env bash
# Fix bind-mount ownership so Prometheus/Loki/Grafana can write data dirs.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

mkdir -p \
  data/prometheus \
  data/loki \
  data/grafana \
  data/alertmanager \
  data/uptime-kuma \
  backups

echo "Setting data directory ownership..."
# Prometheus + Alertmanager images run as nobody (65534)
sudo chown -R 65534:65534 data/prometheus data/alertmanager
# Loki runs as 10001
sudo chown -R 10001:10001 data/loki
# Grafana runs as 472
sudo chown -R 472:472 data/grafana

# Ensure subdirs Loki expects exist and are writable
sudo mkdir -p \
  data/loki/chunks \
  data/loki/rules \
  data/loki/tsdb-index \
  data/loki/tsdb-cache \
  data/loki/compactor \
  data/loki/rules-temp
sudo chown -R 10001:10001 data/loki

echo "Permissions fixed."
ls -la data/
