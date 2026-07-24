# Ports

## Published to host (defaults)

All host binds use `${BIND_ADDRESS:-127.0.0.1}`.

| Default host port | Env var | Container port | Service |
| ----------------- | ------- | -------------- | ------- |
| 3010 | `GRAFANA_PORT` | 3000 | Grafana (`ms-grafana`) |
| 3002 | `UPTIME_KUMA_PORT` | 3001 | Uptime Kuma |
| 9090 | `PROMETHEUS_PORT` | 9090 | Prometheus |
| 9093 | `ALERTMANAGER_PORT` | 9093 | Alertmanager |

## Internal only (no host publish)

These are scraped/reached on the `monitoring` Docker network only:

| Service | Container port |
| ------- | -------------- |
| Node Exporter | 9100 |
| cAdvisor | 8080 |
| Loki | 3100 |
| Promtail | 9080 |

## Homeserver conflict map (observed)

| Host port | Already used by | Our stack choice |
| --------- | --------------- | ---------------- |
| 3000 | Existing Grafana UI | `ms-grafana` → **3010** |
| 3001 | Container `grafana` (`3001->3000`) | Uptime Kuma → **3002** |
| 8080 | Existing service | cAdvisor **not published** |

## Port conflicts

If Compose fails with `Bind for … failed: port is already allocated`:

1. `sudo ss -tlnp | grep <port>`
2. `docker ps --format '{{.Names}}\t{{.Ports}}' | grep <port>`
3. Change the matching `*_PORT` in `.env`, or keep exporters internal-only
4. `docker compose up -d`

**Important:** `curl http://127.0.0.1:3000` may hit an *existing* Grafana, not `ms-grafana`. Always check container name `ms-grafana` and port `GRAFANA_PORT`.
