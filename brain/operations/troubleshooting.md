# Troubleshooting

## Prometheus: `permission denied` on `/prometheus/queries.active`

**Symptom:** `ms-prometheus` restart loop, exit code 2.

**Cause:** `data/prometheus` owned by root (or wrong uid). Image runs as uid `65534`.

```bash
cd /opt/monitoring-service
sudo chown -R 65534:65534 data/prometheus
docker compose up -d prometheus
docker logs --tail 20 ms-prometheus
```

## Loki: `mkdir /loki/rules: permission denied`

**Symptom:** `ms-loki` restart loop, exit code 1.

**Cause:** `data/loki` not writable by uid `10001`.

```bash
cd /opt/monitoring-service
sudo mkdir -p data/loki/{chunks,rules,tsdb-index,tsdb-cache,compactor,rules-temp}
sudo chown -R 10001:10001 data/loki
docker compose up -d loki
docker logs --tail 20 ms-loki
```

## One-shot fix (permissions + recreate)

`chown` alone is sometimes not enough (Docker userns-remap). Prefer `chmod a+rwX` as well:

```bash
cd /opt/monitoring-service
sudo chmod -R a+rwX data/prometheus data/loki data/grafana data/alertmanager
sudo chown -R 65534:65534 data/prometheus data/alertmanager
sudo chown -R 10001:10001 data/loki
sudo chown -R 472:472 data/grafana
docker compose up -d --force-recreate prometheus loki
```

Or, after syncing the latest repo:

```bash
./scripts/fix-permissions.sh
./scripts/apply-homeserver-fix.sh
```

## Grafana: bind 127.0.0.1:3000 already allocated

Host already has another Grafana on **3000**. This stack must use **3010**:

```bash
cd /opt/monitoring-service
# ports line must map host 3010 -> container 3000
sudo sed -i 's/3000:3000/3010:3000/g' docker-compose.yml
grep -E 'GRAFANA_PORT|3010' .env || echo 'GRAFANA_PORT=3010' | sudo tee -a .env
docker compose up -d --force-recreate grafana
```

## Tailscale: Jellyfin works but Grafana :3010 does not

**Cause:** `ms-grafana` was published on `127.0.0.1` only. Jellyfin/qBittorrent listen on `0.0.0.0`, so `http://100.x.x.x:<port>` works for them.

**Fix (match Jellyfin pattern):**

```bash
cd /opt/monitoring-service
# .env
# BIND_ADDRESS=0.0.0.0
# GF_SERVER_ROOT_URL=http://<tailscale-ip>:3010
docker compose up -d --force-recreate grafana
docker ps --format '{{.Names}}\t{{.Ports}}' | grep ms-grafana
```

Open `http://<tailscale-ip>:3010`. Ports should show `0.0.0.0:3010->3000/tcp` (or `*:3010`), not only `127.0.0.1:3010`.

## False-positive health checks

If health-check says Grafana OK on `:3000` or Uptime Kuma OK on `:3001` but `ms-grafana` is missing from `docker compose ps`, you are hitting **other** containers. Use the updated `scripts/health-check.sh` that checks `ms-*` names and ports `3010` / `3002`.
