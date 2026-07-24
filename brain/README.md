# Monitoring Service — Brain

Living documentation for the implemented monitoring stack.  
If code or config changes, **this folder must be updated in the same change**.

| Doc | Purpose |
| --- | ------- |
| [CHANGELOG.md](CHANGELOG.md) | Chronological implementation changes |
| [DOC_SYNC.md](DOC_SYNC.md) | Rules for keeping brain up to date |
| [architecture/overview.md](architecture/overview.md) | Components and boundaries |
| [architecture/data-flow.md](architecture/data-flow.md) | Metrics, logs, alerts paths |
| [operations/deploy.md](operations/deploy.md) | Install and first boot |
| [operations/backup-restore.md](operations/backup-restore.md) | Backup / restore / cleanup |
| [operations/alerts.md](operations/alerts.md) | Alert ownership and Telegram |
| [operations/security.md](operations/security.md) | Bind address, secrets, socket |
| [operations/troubleshooting.md](operations/troubleshooting.md) | Crash loops, permissions, false health OK |
| [reference/services.md](reference/services.md) | Compose services |
| [reference/ports.md](reference/ports.md) | Published ports |
| [reference/env-vars.md](reference/env-vars.md) | Environment variables |
| [phases/](phases/) | Phase status and deliverables |

Related: [`../plan.md`](../plan.md) (product plan), [`../README.md`](../README.md) (quick start).

## Current implementation status

| Phase | Name | Status |
| ----- | ---- | ------ |
| 1 | Infrastructure | Implemented in repo |
| 2 | Metrics core | Implemented in repo |
| 3 | Logs core | Implemented in repo |
| 4 | Grafana | Implemented in repo (MVP dashboards) |
| 5 | Alerting | Implemented in repo (Telegram via env) |
| 6 | Uptime Kuma | Implemented in compose (UI setup on server) |
| 7 | App dashboards | Post-MVP stubs only (documented) |

Runtime validation happens on the Ubuntu host after `docker compose up -d`.
