# Brain changelog

## 2026-07-24

- Initial MVP scaffold created from corrected `plan.md`.
- Added Compose stack: Prometheus, Node Exporter, cAdvisor, Loki, Promtail, Grafana, Alertmanager, Uptime Kuma.
- Added Prometheus rules with `for:` durations (host + containers).
- Added Alertmanager Telegram templating via entrypoint + env vars.
- Added Grafana datasource/dashboard provisioning (Infrastructure, Docker, Logs).
- Added ops scripts: backup, restore, update, health-check, cleanup.
- Created `brain/` knowledge base and Cursor rule for doc sync.
- Default publish bind: `127.0.0.1` via `BIND_ADDRESS`.
- Retention: Prometheus 15d, Loki 14d, backups 30d.
