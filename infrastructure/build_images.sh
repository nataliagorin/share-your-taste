#!/bin/bash
set -e

# Detect Minikube and use its Docker daemon if available
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "🐳 Minikube detected. using minikube's docker environment..."
    eval $(minikube docker-env)
fi

# Build images
echo "Building Auth Service..."
docker build -t shareyourtaste/auth:latest ../auth

echo "Building Albums-Artists Service..."
docker build -t shareyourtaste/albums-artists:latest ../albums-artists

echo "Building Reviews Service..."
docker build -t shareyourtaste/reviews:latest ../reviews

echo "Building Socials Service..."
docker build -t shareyourtaste/socials:latest ../socials

echo "✅ All images built successfully inside the cluster environment!"
echo "You can now run 'kubectl rollout restart deployment' to pick up changes."
