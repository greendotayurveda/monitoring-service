# Brain changelog

## 2026-07-24

- Fixed Uptime Kuma host port conflict: default host port is now **3002** (`UPTIME_KUMA_PORT`) because **3001** is often already allocated.
- Made all published host ports overridable via `.env` (`GRAFANA_PORT`, `PROMETHEUS_PORT`, etc.).
- Updated `scripts/health-check.sh` to read port overrides from `.env`.
- Documented port-conflict recovery in `brain/reference/ports.md`.

- Initial MVP scaffold created from corrected `plan.md`.
- Added Compose stack: Prometheus, Node Exporter, cAdvisor, Loki, Promtail, Grafana, Alertmanager, Uptime Kuma.
- Added Prometheus rules with `for:` durations (host + containers).
- Added Alertmanager Telegram templating via entrypoint + env vars.
- Added Grafana datasource/dashboard provisioning (Infrastructure, Docker, Logs).
- Added ops scripts: backup, restore, update, health-check, cleanup.
- Created `brain/` knowledge base and Cursor rule for doc sync.
- Default publish bind: `127.0.0.1` via `BIND_ADDRESS`.
- Retention: Prometheus 15d, Loki 14d, backups 30d.
