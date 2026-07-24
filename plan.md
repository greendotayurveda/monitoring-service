# Monitoring Service Implementation Plan

## Production-Ready Monitoring Stack for Ubuntu Server

### Deployment Directory: `/opt/monitoring-service`

---

# Version

| Item              | Value                     |
| ----------------- | ------------------------- |
| Project           | Monitoring Service        |
| Platform          | Ubuntu Server             |
| Container Runtime | Docker + Docker Compose   |
| Deployment Path   | `/opt/monitoring-service` |
| Environment       | Production                |
| Architecture      | Single Host               |
| Storage Model     | Bind mounts under `./data` |
| Future Ready      | Multi-server (later)      |
| Document Status   | Corrected implementation plan |

---

# 1. Objectives

The Monitoring Service should provide a centralized platform to monitor every service running on the Ubuntu server.

It should collect:

* Docker container metrics
* Host machine metrics
* Docker logs
* System logs (journal)
* Container health / restart signals
* Resource usage (CPU, memory, disk, network)
* Alerts (metrics-based)
* Service availability (HTTP/TCP checks)
* GitHub Runner status (post-MVP, when exporter/API integration exists)
* AI / Ollama server status (post-MVP, when metrics endpoints exist)

The monitoring service should **not** directly manage application containers. Instead, it should observe, analyze, and report on them.

---

# 2. Goals

## Functional Goals

* Monitor Docker containers
* Collect container logs
* Collect host metrics
* Visualize metrics and logs
* Generate alerts with duration-based rules
* Store historical metrics and logs within defined retention
* Detect unhealthy / down containers
* Monitor disk, memory, CPU, and network usage
* Provide provisioned dashboards
* Send Telegram notifications (with clear ownership per channel)
* Monitor GitHub Runner and AI server **after MVP**, via dedicated exporters/APIs

## Non Functional Goals

* Resource-capped (lightweight relative to the host, not unbounded)
* Easy to upgrade one component at a time
* Completely containerized
* Docker Compose based
* Easy backup and restore from bind-mounted data
* Modular and expandable
* AI-friendly (read-only API access later)
* Secure by default (localhost / private network binding)

---

# 3. High Level Architecture

Correct data paths:

```text
                         Ubuntu Server
                               │
                 Docker Compose Stack (monitoring-service)
                               │
     ┌─────────────────────────┼──────────────────────────┐
     │                         │                          │
     ▼                         ▼                          ▼
Node Exporter              Promtail                  Uptime Kuma
cAdvisor                      │                    (availability)
     │                        │                          │
     ▼                        ▼                          │
Prometheus ──rules──► Alertmanager ──► Telegram/Email    │
     │                        │                          │
     │                        │                          │
     └────────────┬───────────┴──────────┬───────────────┘
                  ▼                      ▼
              Grafana              (Kuma Telegram =
           (metrics + logs)       availability only)
                  │
                  │  read-only APIs (later)
                  ▼
            Local AI Server
```

### Notification ownership

| Channel | Owner | Used for |
| ------- | ----- | -------- |
| Alertmanager → Telegram | Prometheus alert rules | Host/container metrics, disk, restarts |
| Uptime Kuma → Telegram | Uptime Kuma | HTTP/HTTPS/TCP availability only |

Do **not** duplicate the same check in both systems.

### Out of MVP scrape path

GitHub Runner and AI/Ollama are **not** Prometheus scrape targets until a concrete exporter or metrics URL exists. Until then, track them with Uptime Kuma HTTP/TCP checks and/or container metrics via cAdvisor.

---

# 4. Technology Stack

| Component        | Purpose                          | MVP |
| ---------------- | -------------------------------- | --- |
| Docker Compose   | Service orchestration            | Yes |
| Grafana          | Dashboards + log explore         | Yes |
| Prometheus       | Metrics collection + rules       | Yes |
| Loki             | Log storage                      | Yes |
| Promtail         | Log collector                    | Yes |
| Node Exporter    | Host metrics                     | Yes |
| cAdvisor         | Container metrics                | Yes |
| Alertmanager     | Alert routing                    | Yes |
| Uptime Kuma      | Availability monitoring          | Yes |
| Nginx (optional) | Reverse proxy + TLS              | Post-MVP |
| GPU / Ollama exporters | AI metrics                  | Post-MVP |
| Runner / Actions integration | CI status               | Post-MVP |

---

# 5. Directory Structure

Use **bind mounts** under `/opt/monitoring-service/data` for all persistent state. Do not mix named Docker volumes with bind mounts unless a component absolutely requires it.

```text
/opt
└── monitoring-service
    ├── docker-compose.yml
    ├── .env
    ├── .env.example
    ├── README.md
    │
    ├── config
    │   ├── prometheus
    │   │   ├── prometheus.yml
    │   │   └── rules/
    │   ├── grafana
    │   │   ├── provisioning/
    │   │   │   ├── datasources/
    │   │   │   └── dashboards/
    │   │   └── dashboards/
    │   ├── loki
    │   │   └── config.yml
    │   ├── promtail
    │   │   └── config.yml
    │   └── alertmanager
    │       ├── alertmanager.yml
    │       └── templates/
    │
    ├── alerts                    # source alert rule files (synced/mounted into Prometheus)
    ├── scripts
    │   ├── backup.sh
    │   ├── restore.sh
    │   ├── update.sh
    │   ├── health-check.sh
    │   └── cleanup.sh
    │
    ├── backups                   # daily archives (excluded from app runtime mounts)
    ├── data                      # persistent bind mounts
    │   ├── grafana
    │   ├── prometheus
    │   ├── loki
    │   ├── alertmanager
    │   └── uptime-kuma
    │
    └── docs
```

Notes:

* Uptime Kuma config lives in its data directory (app-managed UI state), not under `config/`.
* `logs/` for application log shipping is optional; prefer Docker logging driver + journal via Promtail.
* `.env` holds secrets; `.env.example` is committed without secrets.

---

# 6. Resource Budget and Retention

Defaults assume a home/self-hosted Ubuntu server. Adjust if the host is small.

## Compose resource limits (initial)

| Service       | CPU limit | Memory limit |
| ------------- | --------- | ------------ |
| Prometheus    | 1.0       | 1g           |
| Loki          | 1.0       | 1g           |
| Grafana       | 0.5       | 512m         |
| Promtail      | 0.25      | 256m         |
| Node Exporter | 0.20      | 128m         |
| cAdvisor      | 0.50      | 512m         |
| Alertmanager  | 0.20      | 128m         |
| Uptime Kuma   | 0.30      | 256m         |

Target total monitoring footprint: roughly **2–4 GB RAM** under normal load.

## Data retention

| Store       | Retention | Notes |
| ----------- | --------- | ----- |
| Prometheus  | 15 days   | `--storage.tsdb.retention.time=15d` |
| Loki        | 14 days   | Compactor + retention enabled |
| Backups     | 30 days   | Daily archives under `./backups` |
| Grafana DB  | Indefinite (within backups) | Size stays small |

Disk planning: reserve enough free space for Prometheus + Loki working set plus 30 days of backups. Fail alerts if root or data filesystem exceeds warning/critical thresholds.

## Prometheus scrape defaults

| Setting          | Value |
| ---------------- | ----- |
| scrape_interval  | 15s   |
| evaluation_interval | 15s |
| MVP targets      | `node-exporter:9100`, `cadvisor:8080`, `prometheus:9090` |

Post-MVP targets (only when available):

* Ollama / AI metrics endpoint or GPU exporter
* GitHub Runner metrics exporter or Actions API poller (not a naive “Docker” scrape)

---

# 7. Deployment Phases

---

## Phase 1 — Infrastructure preparation

Tasks

* Create directory structure
* Set ownership/permissions for `data/`, `backups/`, `config/`
* Create Docker network `monitoring`
* Create `.env` from `.env.example`
* Decide publish mode: **localhost / private LAN only** for all UIs and APIs
* Install backup cron skeleton (script present; enabled after data exists)

Deliverables

* Folder structure
* Docker network
* Bind-mount data directories ready
* Documented publish/bind strategy

---

## Phase 2 — Metrics core (Prometheus + exporters)

Ship Prometheus together with its MVP exporters so “metrics available” is a real milestone.

Responsibilities

* Prometheus scrapes and stores metrics
* Node Exporter collects host metrics
* cAdvisor collects container metrics

Node Exporter collects

* CPU, RAM, disk, filesystem, network, load average
* Temperature **when** `hwmon` sensors exist (optional panel; not a hard requirement)

cAdvisor collects

* Per-container CPU, memory, network, IO
* Restart-related signals / uptime patterns
* Image / container inventory signals usable in dashboards

Deliverables

* Prometheus, Node Exporter, and cAdvisor healthy
* Host and container metrics queryable in Prometheus

---

## Phase 3 — Logs core (Loki + Promtail)

Responsibilities

* Loki stores logs with retention limits
* Promtail ships:
  * Docker container logs
  * System journal (optional but recommended)
  * Selected application log paths only if needed

Deliverables

* Logs searchable via Loki API / LogQL
* Retention and ingestion limits active

---

## Phase 4 — Grafana

Responsibilities

* Visualization and Explore
* Authentication enabled (admin password from `.env`)
* Provision Prometheus + Loki datasources
* Provision at least Infrastructure + Docker dashboards

Deliverables

* Grafana reachable on private bind only
* Core dashboards load without manual UI clicks

---

## Phase 5 — Alerting (rules + Alertmanager)

Responsibilities

* Prometheus evaluates alert rules with `for:` durations
* Alertmanager routes by severity
* Telegram (and optional email) for metrics/log-derived alerts
* Grouping, inhibition, and silencing configured

Deliverables

* Test alert received on Telegram
* Critical vs warning routing verified

---

## Phase 6 — Availability (Uptime Kuma)

Responsibilities

* HTTP / HTTPS / TCP checks for critical services
* Optional Docker container monitors where useful
* Telegram notifications **only for availability**

Deliverables

* Critical services listed and green/red status visible
* No duplicate alerting with Alertmanager for the same condition

---

## Phase 7 — Dashboard expansion (app-specific)

Create dashboards in this order. Mark data sources honestly.

### MVP dashboards (from this stack alone)

#### Infrastructure Dashboard

* CPU, RAM, disk, network, uptime
* Temperature (if sensors available)

#### Docker Dashboard

* Running / stopped containers
* Restart count
* Memory, CPU, network
* Volume/disk pressure via host filesystem metrics (not full Docker volume introspection)

#### Logs Dashboard

* Errors, warnings, recent and critical log streams via Loki

### Post-MVP / enhanced dashboards

#### Jellyfin Dashboard

| Panel | Source |
| ----- | ------ |
| Container CPU/memory | cAdvisor |
| Availability | Uptime Kuma |
| Users / stream bandwidth | Jellyfin API or plugin (later) |

#### Home Assistant Dashboard

| Panel | Source |
| ----- | ------ |
| Container health, CPU, memory | cAdvisor |
| Logs | Loki |
| App-level health | HA API / Uptime Kuma (later) |

#### AI Dashboard

| Panel | Source |
| ----- | ------ |
| Container CPU/RAM | cAdvisor |
| GPU | NVIDIA/DCGM or equivalent exporter (later) |
| Requests / latency / model status | Ollama metrics endpoint (later) |

#### GitHub Runner Dashboard

| Panel | Source |
| ----- | ------ |
| Runner container up | cAdvisor / Uptime Kuma |
| Jobs, deployments, failures | GitHub Actions API or runner metrics (later) |

---

# 8. Alert Rules

All metric alerts must include a `for:` duration to avoid flapping.

## Critical

| Condition | Duration | Notes |
| --------- | -------- | ----- |
| CPU > 95% | 10m | Host |
| Memory > 95% | 10m | Host |
| Disk > 90% | 15m | Any critical filesystem |
| Container down (critical apps) | 2m | Named containers only |
| Host unreachable / node exporter down | 2m | |

## Warning

| Condition | Duration | Notes |
| --------- | -------- | ----- |
| CPU > 80% | 15m | Host |
| Memory > 80% | 15m | Host |
| Disk > 80% | 30m | |
| Container restart count increase > 5 | 30m | Per container |
| High network usage | 15m | Set interface-specific threshold during implementation |

## Information (optional / low noise)

Prefer script or CI notifications over Prometheus for these unless a stable metric exists:

* Deployment completed
* Backup completed
* Container updated

Route informational events so they do not page like critical alerts.

---

# 9. Security

## Required for MVP

* Bind Grafana, Prometheus, Loki, Alertmanager, and Uptime Kuma to **localhost or private LAN** only (not public `0.0.0.0` without auth/proxy)
* Strong Grafana and Uptime Kuma admin passwords via `.env`
* Secrets only in `.env` (never committed)
* Read-only mounts for config files
* Docker socket mounts **read-only** where the component supports it (cAdvisor / Promtail)
* Least-privilege container users where images allow
* Host firewall: deny public access to monitoring ports
* Daily backups of data + config

## Post-MVP hardening

* Nginx (or Traefik/Caddy) reverse proxy
* HTTPS with valid certificates
* Optional SSO / additional auth in front of Grafana
* Network isolation: monitoring compose on dedicated bridge; only required egress

## Backup caution

`.env` is included in backups. Treat backup archives as **secret material** (permissions `600`, private storage only).

---

# 10. Backup Strategy

## What to back up

* `data/grafana`
* `data/prometheus`
* `data/loki`
* `data/alertmanager`
* `data/uptime-kuma`
* `docker-compose.yml`
* `config/`
* `alerts/`
* `.env` (secret)

## Schedule

| Item | Value |
| ---- | ----- |
| Frequency | Daily |
| Retention | 30 days |
| Restore test | Monthly |
| Script | `scripts/backup.sh` / `scripts/restore.sh` |

Prefer stopping or using consistent snapshot strategy for Prometheus/Loki when possible; document the chosen approach in `docs/`.

---

# 11. Future AI Integration

The Local AI Server should **consume** monitoring data rather than replace the monitoring stack.

Potential AI capabilities:

* Summarize container logs
* Explain root causes of failures
* Correlate metrics and logs
* Predict storage exhaustion
* Recommend performance tuning
* Detect recurring failures
* Suggest Docker Compose improvements
* Generate incident summaries
* Answer natural-language operational questions

Data sources (read-only):

* Prometheus API
* Loki API
* Docker Engine API (carefully; prefer metrics/logs first)
* GitHub Actions API
* Uptime Kuma API

AI integration is **out of MVP success criteria** except that APIs remain reachable on the private network for later use.

---

# 12. Upgrade Strategy

Perform rolling upgrades one component at a time:

1. Backup persistent data
2. Pull updated image
3. Restart only the target service
4. Validate health (`scripts/health-check.sh`)
5. Verify dashboards and alerts
6. Roll back if necessary

Avoid updating all monitoring components simultaneously.

---

# 13. MVP Definition

MVP is complete when all of the following are true:

* Monitoring containers start automatically after reboot
* Host metrics visible in Grafana
* Docker container metrics visible in Grafana
* Logs from application containers searchable in Grafana via Loki
* At least the Critical and Warning metric alerts deliver to Telegram through Alertmanager with `for:` durations
* Uptime Kuma reports status of critical HTTP/TCP services (availability alerts only)
* Data persists across container restarts via `./data` bind mounts
* Daily backups complete successfully
* Stack can be upgraded one service at a time without losing historical data within retention
* All UIs/APIs are not exposed publicly without authentication

Explicitly **not** required for MVP:

* Nginx / HTTPS
* Multi-server federation
* AI log summarization
* Jellyfin users/bandwidth panels
* GPU / Ollama deep metrics
* GitHub Actions job history panels

---

# 14. Success Criteria (full plan)

The full plan (MVP + post-MVP dashboards/integrations) is considered complete when:

* All MVP criteria above are met
* App-specific dashboards exist with documented data sources
* AI/Ollama and GitHub Runner integrations are wired only through real exporters or APIs
* Optional reverse proxy + HTTPS is in place if remote access is required
* Monthly restore test has succeeded at least once
* Local AI server can access monitoring APIs for future intelligent troubleshooting

---

# Expected Outcome

The `/opt/monitoring-service` stack becomes the central observability platform for the home server. It provides a single place to view infrastructure health, container performance, logs, alerts, and service availability — with bounded retention, clear alert ownership, private-network defaults, and APIs that a local AI server can later use for automated diagnostics and operational recommendations.
