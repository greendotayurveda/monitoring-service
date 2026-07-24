# Phase 3 — Logs core

**Status:** Implemented in repository

## Deliverables

- [x] Loki with 14d retention + compactor
- [x] Promtail Docker service discovery
- [x] Promtail journal scrape (when journal paths exist)
- [x] Ingestion rate limits

## Key files

- `config/loki/config.yml`
- `config/promtail/config.yml`

## Validation

Grafana Explore → Loki → query:

```logql
{job="docker"}
```

## Notes

On some hosts journal paths differ; if journal scrape errors, Docker log scrape still provides MVP value.
