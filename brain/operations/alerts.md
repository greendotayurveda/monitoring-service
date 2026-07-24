# Alerts

## Ownership

| Source | Channel | Use for |
| ------ | ------- | ------- |
| Prometheus → Alertmanager | Telegram (`TELEGRAM_*` in `.env`) | Host/container metric alerts |
| Uptime Kuma | Kuma Telegram notifier (UI) | HTTP/HTTPS/TCP availability |

Never monitor the same failure condition in both systems.

## Metric alert rules (implemented)

Canonical files:

- `config/prometheus/rules/host.yml`
- `config/prometheus/rules/containers.yml`

Mirrored copies for plan layout:

- `alerts/host.yml`
- `alerts/containers.yml`

**Important:** Prometheus loads rules from `config/prometheus/rules/`.  
If you edit `alerts/`, copy changes into `config/prometheus/rules/` (or edit canonical path first) and update brain + CHANGELOG.

### Critical

| Alert | Condition | for |
| ----- | --------- | --- |
| HostHighCPU | CPU > 95% | 10m |
| HostHighMemory | Memory > 95% | 10m |
| HostDiskCritical | `/` disk > 90% | 15m |
| NodeExporterDown | `up{job="node"} == 0` | 2m |
| CriticalContainerDown | missing cAdvisor samples for named apps | 2m |

Critical container name regex (adjust to your apps):

`jellyfin|homeassistant|home-assistant|ollama|github-runner`

### Warning

| Alert | Condition | for |
| ----- | --------- | --- |
| HostCPUWarning | CPU > 80% | 15m |
| HostMemoryWarning | Memory > 80% | 15m |
| HostDiskWarning | `/` disk > 80% | 30m |
| ContainerHighRestarts | `changes(container_start_time_seconds[30m]) > 5` | 30m |

## Telegram setup

1. Create bot with BotFather → token.
2. Get chat id.
3. Set in `.env`:

```env
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=123456789
```

4. Recreate Alertmanager:

```bash
docker compose up -d --force-recreate alertmanager
```

Without these vars, Alertmanager starts with a null receiver (no notifications) so the stack still boots.

## Test alert

In Prometheus UI → Graph, or temporarily lower a threshold in rules, reload:

```bash
curl -X POST http://127.0.0.1:9090/-/reload
```

Confirm message arrives and resolves.
