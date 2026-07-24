#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-archive.tar.gz>"
  exit 1
fi

ARCHIVE="$1"
if [[ ! -f "${ARCHIVE}" ]]; then
  echo "Archive not found: ${ARCHIVE}"
  exit 1
fi

echo "Stopping stack..."
cd "${ROOT_DIR}"
docker compose down

echo "Restoring from ${ARCHIVE}"
tar -xzf "${ARCHIVE}" -C "${ROOT_DIR}"

echo "Starting stack..."
docker compose up -d

echo "Restore complete. Run scripts/health-check.sh to verify."
