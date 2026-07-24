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

## Loki: `creating WAL folder at "/wal": mkdir wal: permission denied`

**Cause:** Loki writes its ingester WAL to `/wal` by default. That path is on the container root FS and is not writable by uid `10001`.

**Fix in repo:** bind-mount host data onto those root paths:

- `./data/loki/wal` → `/wal`
- `./data/loki/rules` → `/rules`
- `./data/loki` → `/loki`

```bash
cd /opt/monitoring-service
git pull
sudo mkdir -p data/loki/wal data/loki/rules data/loki/rules-temp
sudo chmod -R a+rwX data/loki
./scripts/fix-permissions.sh
docker compose up -d --force-recreate loki
docker compose ps | grep loki
docker logs --tail 20 ms-loki
```

## Why healthchecks use `localhost` / `127.0.0.1`

Docker `healthcheck` runs **inside** the container. So `http://127.0.0.1:3100/ready` means “is Loki healthy on itself?”, not your Windows PC and not Tailscale.

Grafana (from another container) still uses `http://loki:3100` on the Docker network.

## Grafana Explore → `lookup loki on 127.0.0.11:53: server misbehaving`

**Cause:** `ms-grafana` cannot resolve Docker DNS name `loki` (wrong/missing network, Loki down, or broken Docker DNS).

**Check:**

```bash
docker compose ps
docker network inspect monitoring --format '{{range .Containers}}{{.Name}} {{end}}'
docker exec ms-grafana wget -qO- http://loki:3100/ready
docker exec ms-grafana getent hosts loki
```

**Fix:**

```bash
cd /opt/monitoring-service
git pull
docker compose up -d --force-recreate loki promtail grafana
# if DNS still broken:
docker compose down
docker network rm monitoring || true
docker compose up -d
```

Confirm you are on **ms-grafana :3010**, not the old `grafana` on :3001 (that container is not on the `monitoring` network).

## Grafana Explore → Loki returns 404

**Cause:** Grafana datasource URL did not match Loki's HTTP path. With `path_prefix: /loki`, URL must be `http://loki:3100/loki`. A mismatch produces **404** on `{job="docker"}`.

**Fix used in this repo:** remove Loki `path_prefix` and use root URLs everywhere:

- Grafana datasource: `http://loki:3100`
- Promtail push: `http://loki:3100/api/v1/push`

On the server, paste the block below, then recreate.

## Grafana Explore → Loki returns no logs

**Common causes on this stack:**

1. **Wrong datasource URL** — Loki uses `path_prefix: /loki`, so Grafana must use `http://loki:3100/loki` (not `http://loki:3100`).
2. **Promtail `__path__` relabel** — breaks native Docker SD; use Docker API scrape only.
3. **`drop: older_than`** — can drop *all* lines if timestamps are missing/epoch.
4. **Old samples rejected** — first backfill 400s; wait for live lines or raise `reject_old_samples_max_age`.

**Fix on server:**

```bash
cd /opt/monitoring-service
# Apply root-URL Loki/Promtail/Grafana datasource configs (see CHANGELOG / repo files)
sudo mkdir -p data/promtail
sudo chmod a+rwX data/promtail
docker compose up -d --force-recreate loki promtail grafana
sleep 5

docker exec ms-loki wget -qO- http://localhost:3100/ready
echo
docker exec ms-loki wget -qO- http://localhost:3100/api/v1/labels
echo
docker exec ms-loki wget -qO- http://localhost:3100/api/v1/label/job/values
echo
docker logs ms-promtail --tail 20
```

In Grafana Explore try (last 15m):

- `{job="docker"}`
- `{job=~".+"}`
- `{container=~".+"}`

If label API is empty, Promtail is still not successfully writing. If labels exist but Explore is empty, hard-refresh Grafana (datasource cache) or restart `ms-grafana`.

Verify datasource in Grafana → Connections → Data sources → Loki → URL is `http://loki:3100` (no `/loki` suffix).

## Promtail: `entry too far behind` / HTTP 400 to Loki

**Cause:** On first start (or when positions are lost in `/tmp`), Promtail backfills old Docker JSON logs. Loki rejects entries older than its accept window (`reject_old_samples_max_age`) or already behind the stream head.

**Impact:** Noisy logs; **recent** logs still ingest once Promtail catches up. Not a crash.

**Fix (in repo):**
- Promtail drops lines older than **24h** before push
- Positions file persisted under `data/promtail/`
- Loki `reject_old_samples_max_age: 336h` + `unordered_writes: true`

On the server after syncing configs:

```bash
cd /opt/monitoring-service
sudo mkdir -p data/promtail
sudo chmod a+rwX data/promtail
docker compose up -d --force-recreate loki promtail
docker logs ms-promtail --tail 30
```

In Grafana Explore → Loki, query `{job="docker"}` for the last 15 minutes — you should see fresh lines even if a few 400s remain during catch-up.

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
