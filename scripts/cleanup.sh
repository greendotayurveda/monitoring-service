#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

echo "Removing dangling docker images (unused)"
docker image prune -f

echo "Pruning backups older than ${BACKUP_RETENTION_DAYS} days"
find "${ROOT_DIR}/backups" -type f -name 'monitoring-backup-*.tar.gz' -mtime "+${BACKUP_RETENTION_DAYS}" -delete || true

echo "Cleanup complete."
