# Phase 7 — App dashboards (post-MVP)

**Status:** Not implemented (documented only)

## Planned dashboards

| Dashboard | MVP possible from cAdvisor/Loki/Kuma? | Needs later |
| --------- | ------------------------------------- | ----------- |
| Jellyfin | Container CPU/mem + availability | Users / bandwidth API |
| Home Assistant | Container + logs + availability | HA API details |
| AI / Ollama | Container resources | GPU exporter + Ollama metrics |
| GitHub Runner | Container / Kuma up | Actions API / runner metrics |

## When implementing

1. Add dashboard JSON under `config/grafana/dashboards/`.
2. Update this phase file status.
3. Update `brain/CHANGELOG.md` and `brain/README.md` status table.
4. Document any new scrape targets in `architecture/data-flow.md` and `reference/services.md`.
