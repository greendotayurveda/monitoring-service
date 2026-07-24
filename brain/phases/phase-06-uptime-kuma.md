# Phase 6 — Uptime Kuma

**Status:** Compose service implemented; monitor list is configured on the server UI

## Deliverables

- [x] Uptime Kuma container + persistent `data/uptime-kuma`
- [ ] Create admin user (first boot on server)
- [ ] Add critical HTTP/HTTPS/TCP monitors
- [ ] Configure Kuma Telegram notifier (availability only)

## Suggested first monitors

- Grafana `http://127.0.0.1:3000`
- Key apps on the host (Jellyfin, Home Assistant, etc.) via their LAN URLs
- Ollama / AI HTTP endpoint if exposed
- GitHub runner host TCP/HTTP health if available

## Rule

Do not also alert the same downtime via Alertmanager.
