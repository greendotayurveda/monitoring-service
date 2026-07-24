# Services reference

Defined in `docker-compose.yml`.

| Service | Container name | Image | Purpose |
| ------- | -------------- | ----- | ------- |
| prometheus | ms-prometheus | prom/prometheus:v2.55.1 | Metrics TSDB + rules |
| node-exporter | ms-node-exporter | prom/node-exporter:v1.8.2 | Host metrics |
| cadvisor | ms-cadvisor | gcr.io/cadvisor/cadvisor:v0.49.1 | Container metrics |
| loki | ms-loki | grafana/loki:3.1.1 | Log store |
| promtail | ms-promtail | grafana/promtail:3.1.1 | Log shipper |
| grafana | ms-grafana | grafana/grafana:11.2.2 | UI / dashboards |
| alertmanager | ms-alertmanager | prom/alertmanager:v0.27.0 | Alert routing |
| uptime-kuma | ms-uptime-kuma | louislam/uptime-kuma:1.23.16 | Availability |

## Resource limits (compose deploy.resources)

| Service | CPU | Memory |
| ------- | --- | ------ |
| prometheus | 1.0 | 1G |
| loki | 1.0 | 1G |
| grafana | 0.5 | 512M |
| promtail | 0.25 | 256M |
| node-exporter | 0.20 | 128M |
| cadvisor | 0.50 | 512M |
| alertmanager | 0.20 | 128M |
| uptime-kuma | 0.30 | 256M |

## Restart policy

All services: `restart: unless-stopped`.
