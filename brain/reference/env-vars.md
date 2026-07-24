# Environment variables

Source template: `.env.example`  
Runtime file: `.env` (not committed)

| Variable | Required | Default | Purpose |
| -------- | -------- | ------- | ------- |
| `BIND_ADDRESS` | No | `127.0.0.1` | Host interface for published ports |
| `UPTIME_KUMA_PORT` | No | `3002` | Host port for Uptime Kuma UI |
| `GRAFANA_PORT` | No | `3000` | Host port for Grafana |
| `PROMETHEUS_PORT` | No | `9090` | Host port for Prometheus |
| `ALERTMANAGER_PORT` | No | `9093` | Host port for Alertmanager |
| `LOKI_PORT` | No | `3100` | Host port for Loki |
| `CADVISOR_PORT` | No | `8080` | Host port for cAdvisor |
| `NODE_EXPORTER_PORT` | No | `9100` | Host port for Node Exporter |
| `GF_SECURITY_ADMIN_USER` | No | `admin` | Grafana admin user |
| `GF_SECURITY_ADMIN_PASSWORD` | **Yes** | — | Grafana admin password |
| `GF_SERVER_ROOT_URL` | No | `http://127.0.0.1:3000` | Grafana root URL |
| `TELEGRAM_BOT_TOKEN` | For metric alerts | empty | Alertmanager Telegram bot |
| `TELEGRAM_CHAT_ID` | For metric alerts | empty | Alertmanager Telegram chat id |
| `SMTP_*` | No | empty | Reserved for future email receiver |
| `BACKUP_RETENTION_DAYS` | No | `30` | Used by backup/cleanup scripts |
