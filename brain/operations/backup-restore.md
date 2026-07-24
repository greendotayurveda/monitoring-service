# Backup and restore

## What is backed up

`scripts/backup.sh` archives:

- `docker-compose.yml`
- `.env` (**contains secrets**)
- `config/`
- `alerts/`
- `data/` (Grafana, Prometheus, Loki, Alertmanager, Uptime Kuma)

Output: `backups/monitoring-backup-YYYYMMDD-HHMMSS.tar.gz`  
Retention: **30 days** (`BACKUP_RETENTION_DAYS`).

## Backup

```bash
./scripts/backup.sh
```

Treat archives as secret (`chmod 600` directory recommended).

## Restore

```bash
./scripts/restore.sh backups/monitoring-backup-YYYYMMDD-HHMMSS.tar.gz
./scripts/health-check.sh
```

Restore stops the stack, extracts archive into the project root, then starts Compose again.

## Update one service safely

```bash
./scripts/update.sh grafana
```

Runs backup → pull → recreate single service → health check.

## Cleanup

```bash
./scripts/cleanup.sh
```

Prunes dangling images and old backup archives.

## Monthly restore test

1. Copy a backup to a scratch directory or staging host.
2. Restore and run `health-check.sh`.
3. Confirm Grafana dashboards and a Loki query work.
4. Record result in ops notes / CHANGELOG if process changes.
