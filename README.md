# ShareYourTaste Infrastructure

## Quick Start

### 1. Prerequisites
- Docker
- Minikube
- Helm
- kubectl

### 2. Environment Setup
```bash
minikube start
```

### 3. Build Images
```bash
./build_images.sh
```

### 4. Deploy with Helm
```bash
helm install shareyourtaste ./helm/shareyourtaste --create-namespace --namespace shareyourtaste
```

Wait for pods:
```bash
kubectl get pods -n shareyourtaste -w
```

### 5. Configure Kong Routes
```bash
./scripts/setup_kong.sh
```

## Accessing Services

| Service | Command | Credentials |
|---------|---------|-------------|
| Kong Gateway | `minikube service kong -n shareyourtaste --url` | - |
| Grafana | `minikube service grafana -n shareyourtaste --url` | admin / admin |
| Adminer | `minikube service adminer -n shareyourtaste --url` | See values.yaml |
| Portainer | `minikube service portainer -n shareyourtaste --url` | Set on first login |
| Prometheus | `minikube service prometheus -n shareyourtaste --url` | - |

## Testing

Run all endpoint tests:
```bash
./scripts/test_endpoints.sh
```

Manual testing:
```bash
KONG_URL=$(minikube service kong -n shareyourtaste --url | head -1)
curl $KONG_URL/albums/
curl $KONG_URL/reviews/
curl -X POST $KONG_URL/auth/token -d "username=admin&password=secret"
```

## Cleanup

```bash
helm uninstall shareyourtaste -n shareyourtaste
minikube stop
```

## Scripts Reference

| Script | Description |
|--------|-------------|
| `build_images.sh` | Builds Docker images in Minikube environment |
| `scripts/setup_kong.sh` | Configures Kong API Gateway routes |
| `scripts/test_endpoints.sh` | Tests all API endpoints |
