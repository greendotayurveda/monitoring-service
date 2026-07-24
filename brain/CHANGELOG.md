# Brain changelog

## 2026-07-24

- Hardened Loki WAL fix: compose now sets `working_dir: /loki`, user `10001`, and CLI `-ingester.wal.dir=/loki/wal` (config-only was still resolving to `/wal` on homeserver).
- Fixed Loki crash-loop: set `ingester.wal.dir: /loki/wal` (default `/wal` is not writable for uid 10001).
- Fixed Grafana→Loki DNS/`server misbehaving`: keep service on `monitoring` network with alias `loki`; Promtail push URL restored to `/loki/api/v1/push`; healthy `depends_on` for Grafana/Promtail.
- Documented git workflow: commit/push only from Windows repo; homeserver `git pull` + compose recreate.
- Promtail Docker SD without `__path__`; positions in `data/promtail`.
- Tailscale: `BIND_ADDRESS=0.0.0.0` for Jellyfin-like access.
- Strengthened `fix-permissions.sh` with `chmod a+rwX` + busybox `chown` (handles Docker userns cases where host `chown` alone fails).
- Confirmed homeserver crash-loop root cause from logs: Prometheus `permission denied` on `/prometheus/queries.active`; Loki `mkdir /loki/rules: permission denied`. Documented in `brain/operations/troubleshooting.md`.
- Homeserver still on old compose: Grafana bind fails on **:3000**; must use **:3010**.
- Homeserver recovery: cAdvisor/Node Exporter/Loki no longer publish host ports (avoids **8080** clash; scrape stays on Docker network).
- Default `GRAFANA_PORT` changed to **3010** (host **3000** already has another Grafana).
- Added `scripts/fix-permissions.sh` and `scripts/apply-homeserver-fix.sh` for data dir ownership (Prometheus 65534, Loki 10001, Grafana 472).
- Simplified Loki config (`allow_structured_metadata: false`, ring `instance_addr` under `common.ring`).
- Health-check now verifies `ms-*` container names and internal endpoints (avoids false OK from other stacks on 3000/3001/8080).
- Port conflict note: host **3001** used by existing container `grafana`; **8080** already allocated on homeserver.
- Uptime Kuma default host port **3002** (`UPTIME_KUMA_PORT`).
- Initial MVP scaffold created from corrected `plan.md`.
- Added Compose stack: Prometheus, Node Exporter, cAdvisor, Loki, Promtail, Grafana, Alertmanager, Uptime Kuma.
- Added Prometheus rules with `for:` durations (host + containers).
- Added Alertmanager Telegram templating via entrypoint + env vars.
- Added Grafana datasource/dashboard provisioning (Infrastructure, Docker, Logs).
- Added ops scripts: backup, restore, update, health-check, cleanup.
- Created `brain/` knowledge base and Cursor rule for doc sync.
- Default publish bind: `127.0.0.1` via `BIND_ADDRESS`.
- Retention: Prometheus 15d, Loki 14d, backups 30d.
