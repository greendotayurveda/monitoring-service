# Phase 1 — Infrastructure

**Status:** Implemented in repository

## Deliverables

- [x] Directory tree (`config/`, `data/`, `backups/`, `scripts/`, `alerts/`, `docs/`, `brain/`)
- [x] Docker Compose network `monitoring`
- [x] Bind-mount data directories with `.gitkeep`
- [x] `.env.example` + local `.env` template copy
- [x] Backup/restore/update/health/cleanup script skeletons
- [x] Documented publish strategy (`BIND_ADDRESS`)
- [x] `scripts/fix-permissions.sh` for bind-mount ownership

## How to complete on server

```bash
cd /opt/monitoring-service
cp .env.example .env
# set GF_SECURITY_ADMIN_PASSWORD
chmod +x scripts/*.sh
./scripts/fix-permissions.sh
# network is created automatically by compose
```

## Notes

Named Docker volumes are **not** used. Persistence is under `./data`.
