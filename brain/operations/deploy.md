# Deploy

## Prerequisites (Ubuntu)

- Docker Engine + Docker Compose plugin
- User in `docker` group (or use `sudo`)
- Enough free disk for 15d metrics + 14d logs + 30d backups
- Recommended free RAM headroom: **2–4 GB** for this stack

## Install from this repo

```bash
sudo mkdir -p /opt/monitoring-service
sudo rsync -a --exclude '.git' ./ /opt/monitoring-service/
cd /opt/monitoring-service
cp .env.example .env
nano .env   # set passwords + Telegram
chmod +x scripts/*.sh
./scripts/fix-permissions.sh
docker compose up -d
./scripts/health-check.sh
```

## Homeserver with existing Grafana / occupied ports

Sync updated files into `/opt/monitoring-service`, then:

```bash
cd /opt/monitoring-service
chmod +x scripts/*.sh
./scripts/apply-homeserver-fix.sh
```

Defaults avoid common clashes: Grafana **3010**, Uptime Kuma **3002**, cAdvisor internal-only.

## First-login checklist

1. Open **this stack’s** Grafana: `http://127.0.0.1:3010` (not :3000 — that may be another Grafana).
2. Confirm dashboards folder **Monitoring Service** contains Infrastructure, Docker, Logs.
3. Prometheus targets page: `prometheus`, `node`, `cadvisor` all **UP**.
4. Grafana Explore → Loki: see container logs.
5. Set Telegram vars in `.env`, recreate Alertmanager:  
   `docker compose up -d --force-recreate alertmanager`
6. Open Uptime Kuma `http://127.0.0.1:3002`, create admin, add monitors, configure **Kuma** Telegram for availability only.
7. If Compose fails with `port is already allocated`, see [../reference/ports.md](../reference/ports.md).
8. If Prometheus/Loki restart loop: `./scripts/fix-permissions.sh` then `docker compose up -d`.
9. Schedule daily backup cron, e.g.:

```cron
15 3 * * * /opt/monitoring-service/scripts/backup.sh >> /opt/monitoring-service/backups/cron.log 2>&1
```

## Bind address

Default `BIND_ADDRESS=127.0.0.1` (localhost only).

For LAN access from trusted network only:

```env
BIND_ADDRESS=0.0.0.0
```

Then restrict with host firewall. Prefer SSH tunnel or reverse proxy (post-MVP) over public exposure.

## Verify after reboot

```bash
cd /opt/monitoring-service
docker compose ps
./scripts/health-check.sh
```

All services use `restart: unless-stopped`.
