# Architecture overview

## Boundary

The monitoring stack **observes** host and containers. It does **not** create, update, or recreate application containers.

## Deployment model

- **Host:** Ubuntu Server
- **Path:** `/opt/monitoring-service` (production)
- **Orchestration:** Docker Compose project `monitoring-service`
- **Network:** bridge network named `monitoring`
- **Persistence:** bind mounts under `./data/*` (not named volumes)

## Components

| Component | Role |
| --------- | ---- |
| Node Exporter | Host metrics |
| cAdvisor | Container metrics |
| Prometheus | Scrape, store metrics, evaluate rules |
| Alertmanager | Route metric alerts (Telegram) |
| Promtail | Ship Docker + journal logs |
| Loki | Store logs (14d retention) |
| Grafana | Dashboards + Explore |
| Uptime Kuma | HTTP/TCP availability (separate notifier) |

## Storage layout

```text
data/
  grafana/
  prometheus/
  loki/
  alertmanager/
  uptime-kuma/
```

Configs are read-only mounts from `config/`.

## Post-MVP (not in critical path)

- Nginx / HTTPS reverse proxy
- GPU / Ollama exporters
- GitHub Actions / runner deep metrics
- App-specific API panels (Jellyfin users, etc.)
- Local AI consuming Prom/Loki APIs
