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

| Service      | URL (defaults)              |
| ------------ | --------------------------- |
| Grafana      | http://127.0.0.1:3010       |
| Prometheus   | http://127.0.0.1:9090       |
| Alertmanager | http://127.0.0.1:9093       |
| Uptime Kuma  | http://127.0.0.1:3002       |

Loki / cAdvisor / Node Exporter are **internal-only** (no host ports).  
On a host that already has Grafana, use **3010** — do not assume `:3000` is this stack.

Homeserver recovery: `./scripts/apply-homeserver-fix.sh`

See [brain/operations/deploy.md](brain/operations/deploy.md) for full deployment steps.
