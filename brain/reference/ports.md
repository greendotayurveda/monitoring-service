# Ports

All host binds use `${BIND_ADDRESS:-127.0.0.1}`.

| Port | Service | Path / notes |
| ---- | ------- | ------------ |
| 3000 | Grafana | UI |
| 3001 | Uptime Kuma | UI |
| 9090 | Prometheus | UI + API |
| 9093 | Alertmanager | UI + API |
| 3100 | Loki | API |
| 9100 | Node Exporter | `/metrics` |
| 8080 | cAdvisor | UI + `/metrics` |

Promtail listens internally on `9080` (not published).
