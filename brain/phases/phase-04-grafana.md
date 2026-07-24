# Phase 4 — Grafana

**Status:** Implemented in repository (MVP dashboards)

## Deliverables

- [x] Grafana service with admin auth from `.env`
- [x] Provisioned Prometheus + Loki datasources
- [x] Provisioned dashboards:
  - Infrastructure (`ms-infrastructure`)
  - Docker (`ms-docker`)
  - Logs (`ms-logs`)

## Key files

- `config/grafana/provisioning/datasources/datasources.yml`
- `config/grafana/provisioning/dashboards/dashboards.yml`
- `config/grafana/dashboards/*.json`

## Validation

Open `http://127.0.0.1:3000` → folder **Monitoring Service**.
