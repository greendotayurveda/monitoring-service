# Documentation sync policy

## Why

`brain/` is the source of truth for **what is actually implemented**.  
`plan.md` is the product plan and may intentionally look ahead.

## When to update

Update `brain/` whenever any of these change:

- `docker-compose.yml` services, images, ports, volumes, limits
- Files under `config/`
- Scripts under `scripts/`
- Alert rules under `config/prometheus/rules/` or `alerts/`
- `.env.example`
- Provisioned Grafana dashboards
- Security / bind / backup behavior

## Checklist (every change)

1. Edit the matching brain page(s).
2. Append an entry to `CHANGELOG.md` with date (`YYYY-MM-DD`) and summary.
3. Adjust phase status tables if a phase moved forward.
4. Update `reference/*` if ports, env vars, or services changed.
5. Keep post-MVP items labeled; do not claim they are live.

## Automation aid

Project rule: `.cursor/rules/brain-docs.mdc` (`alwaysApply: true`) instructs the Cursor agent to follow this policy automatically.
