# Phase 5 — Alerting

**Status:** Implemented in repository

## Deliverables

- [x] Host critical/warning rules with `for:` durations
- [x] Container critical/warning rules
- [x] Alertmanager wired from Prometheus
- [x] Telegram receiver via env + entrypoint template
- [x] Null-receiver fallback when Telegram unset

## Key files

- `config/prometheus/rules/*.yml`
- `config/alertmanager/alertmanager.yml.template`
- `scripts/alertmanager-entrypoint.sh`

## Validation

1. Set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`
2. `docker compose up -d --force-recreate alertmanager`
3. Trigger a test alert / temporarily lower threshold
4. Confirm Telegram delivery

See [../operations/alerts.md](../operations/alerts.md).
