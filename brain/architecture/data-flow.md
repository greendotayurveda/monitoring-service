# Data flow

## Metrics

```text
Node Exporter (:9100) ──┐
cAdvisor (:8080) ───────┼──► Prometheus (:9090) ──► Grafana
Prometheus self ────────┘           │
                                    ├── rules ──► Alertmanager (:9093) ──► Telegram
                                    └── TSDB (15d) under data/prometheus
```

MVP scrape jobs (see `config/prometheus/prometheus.yml`):

- `prometheus`
- `node`
- `cadvisor`

## Logs

```text
Docker containers ── docker.sock / json logs ──► Promtail ──► Loki (:3100) ──► Grafana Explore
systemd journal ───────────────────────────────► Promtail ──┘
```

Loki retention: **14 days** (`limits_config.retention_period: 336h` + compactor).

## Availability

```text
Critical HTTP/TCP targets ──► Uptime Kuma (:3001) ──► Telegram (Kuma notifier only)
```

Do **not** duplicate the same availability check as a Prometheus alert.

## AI (future)

```text
Local AI Server ── read-only ──► Prometheus API / Loki API / Uptime Kuma API / Docker API
```

AI is not in the alerting path.
