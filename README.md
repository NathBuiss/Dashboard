# Tools Dashboard for Kubernetes

A modern dashboard for accessing and managing your tools and services in Kubernetes. Automatically discovers services with Traefik annotations and provides cluster monitoring.

## Features

- **Automatic Service Discovery**: Discovers services in your cluster that have Traefik annotations
- **Cluster Metrics**: Monitor node and pod resource usage with interactive charts
- **Administration Panel**: Manage dashboard configuration through the admin interface
- **Responsive Design**: Works on desktop and mobile
- **Secure Access**: Protected with basic authentication
- **Helm Chart Deployment**: Easy deployment with customizable values

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3+
- Traefik ingress controller
- `kubectl` configured for your cluster

## Installation

```bash
# Deploy with the provided script
chmod +x deploy.sh
./deploy.sh

# Or deploy directly with Helm
helm upgrade --install tools-dashboard . \
  --namespace tools \
  --create-namespace
```

## Configuration

Edit `values.yaml` or use `--set` flags:

```bash
helm upgrade --install tools-dashboard . \
  --namespace tools \
  --set dashboard.ingress.host=my-dashboard.example.com \
  --set dashboard.env.ADMIN_USERNAME=admin \
  --set dashboard.env.ADMIN_PASSWORD=changeme
```

Key values:

| Key | Default | Description |
|-----|---------|-------------|
| `dashboard.ingress.host` | `dashboard.tools.example.com` | Ingress hostname |
| `dashboard.replicas` | `1` | Number of pod replicas |
| `dashboard.env.ADMIN_USERNAME` | `admin` | Admin username |
| `dashboard.env.ADMIN_PASSWORD` | `admin123` | Admin password — **change in production** |
| `dashboard.resources.limits.memory` | `256Mi` | Memory limit |
| `serviceAccount.create` | `true` | Create a dedicated service account |

## Development

All application code (server, views, JS, CSS) lives in `templates/configmap.yaml`. To modify the UI or server logic:

1. Edit the relevant section in `templates/configmap.yaml`
2. Redeploy:
   ```bash
   helm upgrade tools-dashboard . --namespace tools
   ```

To rebuild the Docker image:
```bash
docker build -t tools-dashboard:latest .
```
Then update `dashboard.image` in `values.yaml`.

## Dashboard Pages

- **Home** (`/`) — Overview with quick links
- **Services** (`/services`) — Traefik-annotated services with direct access links
- **Metrics** (`/metrics`) — Node/pod resource usage charts, auto-refreshes every 30s
- **Admin** (`/admin`) — Enable/disable pages, edit titles and paths

## API Endpoints

- `GET /api/pages` — Retrieve dashboard configuration
- `POST /api/pages` — Update configuration (authenticated)
- `GET /api/k8s/*` — Proxy to Kubernetes API (authenticated)

## Troubleshooting

**Dashboard not accessible**: Verify ingress host DNS and Traefik setup.

**No services discovered**: Check that services have Traefik annotations and the RBAC Role has correct permissions.

**Metrics not displaying**: Verify `metrics-server` is installed in the cluster.

## License

MIT — see [LICENSE](LICENSE).
