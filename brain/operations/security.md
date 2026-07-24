# Security

## Defaults implemented

- Published ports bound to `BIND_ADDRESS` (default `127.0.0.1`)
- Grafana sign-up disabled
- Admin password required via `.env` (`GF_SECURITY_ADMIN_PASSWORD`)
- Config mounts read-only
- Promtail docker.sock mounted **read-only**
- `.env` gitignored
- Backup archives include `.env` → treat as secret

## Hardening checklist (host)

- [ ] Firewall denies public access to 3000/3001/9090/9093/9100/8080/3100
- [ ] Prefer SSH tunnel for remote Grafana access
- [ ] Strong Grafana + Uptime Kuma passwords
- [ ] `backups/` directory permissions restricted to admin user
- [ ] Do not commit `.env` or backup tarballs

## Known privileged components

- **cAdvisor** runs privileged and mounts host paths (required for container metrics). Limit exposure of port `8080`.
- **Node Exporter** uses host PID + rootfs bind (read-only). Limit exposure of port `9100`.

## Post-MVP

- Reverse proxy (Nginx/Caddy/Traefik)
- HTTPS certificates
- Optional SSO in front of Grafana
- Dedicated monitoring Docker network egress controls
