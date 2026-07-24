#!/bin/sh
set -eu

TEMPLATE=/etc/alertmanager/alertmanager.yml.template
TARGET=/tmp/alertmanager.yml

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  sed \
    -e "s|TELEGRAM_BOT_TOKEN_PLACEHOLDER|${TELEGRAM_BOT_TOKEN}|g" \
    -e "s|TELEGRAM_CHAT_ID_PLACEHOLDER|${TELEGRAM_CHAT_ID}|g" \
    "$TEMPLATE" > "$TARGET"
else
  echo "TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID unset; using null receiver fallback"
  cat > "$TARGET" <<'EOF'
global:
  resolve_timeout: 5m
route:
  receiver: "null"
  group_by: ["alertname", "severity"]
receivers:
  - name: "null"
EOF
fi

exec /bin/alertmanager \
  --config.file="$TARGET" \
  --storage.path=/alertmanager \
  "$@"
