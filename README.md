# ShareYourTaste

> A cloud-native social platform for music lovers — share albums, write reviews, and connect with others.

Built as a **Cloud Computing** university project, this platform demonstrates a full microservices architecture deployed on Kubernetes using Helm, with an API Gateway, observability stack, and database management tools.

---

## Architecture

The platform is composed of the following microservices, all orchestrated via Kubernetes and exposed through Kong API Gateway:

| Service | Description |
|---------|-------------|
| `albums-artists` | Manage music albums and artists |
| `auth` | User authentication & JWT token issuance |
| `reviews` | Write and read album reviews |
| `socials` | Social interactions between users |

---

## Tech Stack

- **Runtime**: Python (FastAPI) + Uvicorn
- **Database**: PostgreSQL (per-service)
- **Container Orchestration**: Kubernetes (Minikube)
- **Package Manager**: Helm
- **API Gateway**: Kong
- **Monitoring**: Prometheus + Grafana
- **Management Tools**: Adminer (DB UI), Portainer (container UI)

---

## Quick Start

### Prerequisites

- [Docker](https://www.docker.com/)
- [Minikube](https://minikube.sigs.k8s.io/)
- [Helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### 1. Start the cluster

```bash
minikube start
```

### 2. Build Docker images

```bash
./infrastructure/build_images.sh
```

### 3. Deploy with Helm

```bash
helm install shareyourtaste ./infrastructure/helm/shareyourtaste \
  --create-namespace \
  --namespace shareyourtaste
```

### 4. Wait for all pods to be ready

```bash
kubectl get pods -n shareyourtaste -w
```

### 5. Configure Kong API Gateway routes

```bash
./infrastructure/scripts/setup_kong.sh
```

---

## Accessing Services

Once deployed, use the following commands to get each service's URL:

| Service | Command | Credentials |
|---------|---------|-------------|
| **Kong Gateway** | `minikube service kong -n shareyourtaste --url` | — |
| **Grafana** | `minikube service grafana -n shareyourtaste --url` | `admin` / `admin` |
| **Adminer** | `minikube service adminer -n shareyourtaste --url` | See `values.yaml` |
| **Portainer** | `minikube service portainer -n shareyourtaste --url` | Set on first login |
| **Prometheus** | `minikube service prometheus -n shareyourtaste --url` | — |

---

## Testing

Run the full automated test suite:

```bash
./infrastructure/scripts/test_endpoints.sh
```

Or test manually via curl:

```bash
KONG_URL=$(minikube service kong -n shareyourtaste --url | head -1)

# Albums
curl $KONG_URL/albums/

# Reviews
curl $KONG_URL/reviews/

# Auth
curl -X POST $KONG_URL/auth/token -d "username=admin&password=secret"
```

---

## Project Structure

```
.
├── albums-artists/        # Albums & artists microservice
├── auth/                  # Authentication microservice
├── reviews/               # Reviews microservice
├── socials/               # Socials microservice
└── infrastructure/
    ├── helm/
    │   └── shareyourtaste/ # Helm chart for full deployment
    ├── scripts/
    │   ├── setup_kong.sh   # Kong route configuration
    │   └── test_endpoints.sh # Endpoint tests
    └── build_images.sh     # Docker image builder
```

---

## Cleanup

```bash
helm uninstall shareyourtaste -n shareyourtaste
minikube stop
```
