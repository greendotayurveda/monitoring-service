# Ports

All host binds use `${BIND_ADDRESS:-127.0.0.1}` plus overridable host ports from `.env`.

| Default host port | Env var | Container port | Service |
| ----------------- | ------- | -------------- | ------- |
| 3000 | `GRAFANA_PORT` | 3000 | Grafana |
| 3002 | `UPTIME_KUMA_PORT` | 3001 | Uptime Kuma |
| 9090 | `PROMETHEUS_PORT` | 9090 | Prometheus |
| 9093 | `ALERTMANAGER_PORT` | 9093 | Alertmanager |
| 3100 | `LOKI_PORT` | 3100 | Loki |
| 9100 | `NODE_EXPORTER_PORT` | 9100 | Node Exporter |
| 8080 | `CADVISOR_PORT` | 8080 | cAdvisor |

Promtail listens internally on `9080` (not published).

## Port conflicts

If Compose fails with `Bind for … failed: port is already allocated`:

1. Find the process/container: `sudo ss -tlnp | grep <port>` or `docker ps --format '{{.Names}} {{.Ports}}'`
2. Either stop the other service, or set a free host port in `.env` (e.g. `UPTIME_KUMA_PORT=3002`)
3. Re-run `docker compose up -d`

Uptime Kuma host port defaults to **3002** because **3001** is commonly used by an existing Kuma instance.
