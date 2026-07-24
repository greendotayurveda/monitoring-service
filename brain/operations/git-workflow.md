# Git workflow

## Rule

- **Commit and push only from the Windows development machine** (`d:\Deepu\Development\Monitoring Service`).
- **Homeserver only pulls** — do not edit stack YAML by hand on `/opt/monitoring-service` (except secrets in `.env`).

## Dev machine (source of truth)

```powershell
cd "d:\Deepu\Development\Monitoring Service"
# edit configs / compose / brain
git add -A
git commit -m "meaningful message"
git push
```

## Homeserver (deploy)

```bash
cd /opt/monitoring-service
git pull
# keep local .env (never commit secrets)
chmod +x scripts/*.sh
./scripts/fix-permissions.sh   # when data dirs need ownership fix
docker compose up -d
./scripts/health-check.sh
```

If a service config changed:

```bash
docker compose up -d --force-recreate <service>
# examples: loki promtail grafana prometheus
```

## Do not

- `tee` / manually overwrite `config/**/*.yml` on the server for permanent fixes
- Commit from the homeserver
- Commit `.env` or `data/**` or `backups/**`
