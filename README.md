# Monitoring Service

Production-oriented observability stack for Ubuntu Server (Docker Compose).

**Canonical documentation lives in [`brain/`](brain/README.md).**  
`plan.md` is the product plan; `brain/` is the living implementation knowledge base.

## Quick start (Ubuntu)

```bash
sudo mkdir -p /opt/monitoring-service
sudo rsync -a ./ /opt/monitoring-service/
cd /opt/monitoring-service
cp .env.example .env
# edit .env — set GF_SECURITY_ADMIN_PASSWORD and Telegram values
chmod +x scripts/*.sh
docker compose up -d
./scripts/health-check.sh
```

UI (default bind `127.0.0.1`):

| Service      | URL                         |
| ------------ | --------------------------- |
| Grafana      | http://127.0.0.1:3000       |
| Prometheus   | http://127.0.0.1:9090       |
| Alertmanager | http://127.0.0.1:9093       |
| Loki         | http://127.0.0.1:3100       |
| Uptime Kuma  | http://127.0.0.1:3001       |

See [brain/operations/deploy.md](brain/operations/deploy.md) for full deployment steps.
