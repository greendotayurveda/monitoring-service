# Phase 2 — Metrics core

**Status:** Implemented in repository

## Deliverables

- [x] Prometheus with 15d retention
- [x] Node Exporter scrape job
- [x] cAdvisor scrape job
- [x] Self scrape job
- [x] Resource limits in compose

## Key files

- `docker-compose.yml` → `prometheus`, `node-exporter`, `cadvisor`
- `config/prometheus/prometheus.yml`

## Validation

```bash
curl -s http://127.0.0.1:9090/api/v1/targets | jq '.data.activeTargets[].labels.job'
# expect: prometheus, node, cadvisor
```

## Out of scope here

GitHub Runner / AI exporters (post-MVP).
