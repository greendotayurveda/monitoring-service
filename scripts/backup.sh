#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="${BACKUP_DIR}/monitoring-backup-${STAMP}.tar.gz"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

mkdir -p "${BACKUP_DIR}"

echo "Creating backup: ${ARCHIVE}"
tar -czf "${ARCHIVE}" \
  -C "${ROOT_DIR}" \
  docker-compose.yml \
  .env \
  config \
  alerts \
  data

echo "Pruning backups older than ${RETENTION_DAYS} days"
find "${BACKUP_DIR}" -type f -name 'monitoring-backup-*.tar.gz' -mtime "+${RETENTION_DAYS}" -delete || true

echo "Backup complete: ${ARCHIVE}"
