#!/bin/sh
# Prepare writable dirs then start Loki (run container as root).
set -eu
mkdir -p \
  /wal \
  /rules \
  /loki/chunks \
  /loki/rules \
  /loki/rules-temp \
  /loki/wal \
  /loki/compactor \
  /loki/tsdb-index \
  /loki/tsdb-cache
chmod -R 0777 /wal /rules /loki 2>/dev/null || true
exec /usr/bin/loki "$@"
