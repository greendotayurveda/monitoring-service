# Environment variables

Source template: `.env.example`  
Runtime file: `.env` (not committed)

| Variable | Required | Default | Purpose |
| -------- | -------- | ------- | ------- |
| `BIND_ADDRESS` | No | `127.0.0.1` | Host interface for published ports |
| `GF_SECURITY_ADMIN_USER` | No | `admin` | Grafana admin user |
| `GF_SECURITY_ADMIN_PASSWORD` | **Yes** | — | Grafana admin password |
| `GF_SERVER_ROOT_URL` | No | `http://127.0.0.1:3000` | Grafana root URL |
| `TELEGRAM_BOT_TOKEN` | For metric alerts | empty | Alertmanager Telegram bot |
| `TELEGRAM_CHAT_ID` | For metric alerts | empty | Alertmanager Telegram chat id |
| `SMTP_*` | No | empty | Reserved for future email receiver |
| `BACKUP_RETENTION_DAYS` | No | `30` | Used by backup/cleanup scripts |
