#!/bin/bash
set -e

# Get Kong Admin URL dynamically
KONG_ADMIN_URL=$(minikube service kong -n shareyourtaste --url | tail -1)
echo "Configuring Kong at ${KONG_ADMIN_URL}..."

# Delete existing services (ignore errors if they don't exist)
echo "Cleaning up existing services..."
curl -s -X DELETE ${KONG_ADMIN_URL}/services/auth-service 2>/dev/null || true
curl -s -X DELETE ${KONG_ADMIN_URL}/services/albums-service 2>/dev/null || true
curl -s -X DELETE ${KONG_ADMIN_URL}/services/reviews-service 2>/dev/null || true
curl -s -X DELETE ${KONG_ADMIN_URL}/services/socials-service 2>/dev/null || true

# Add Services with correct ports
echo "Adding Services..."
curl -s -X POST ${KONG_ADMIN_URL}/services --data "name=auth-service" --data "url=http://auth.shareyourtaste.svc.cluster.local:8004" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services --data "name=albums-service" --data "url=http://albums-artists.shareyourtaste.svc.cluster.local:8005" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services --data "name=reviews-service" --data "url=http://reviews.shareyourtaste.svc.cluster.local:8002" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services --data "name=socials-service" --data "url=http://socials.shareyourtaste.svc.cluster.local:8003" > /dev/null

# Add Routes
echo "Adding Routes..."
curl -s -X POST ${KONG_ADMIN_URL}/services/auth-service/routes --data "name=auth-route" --data "paths[]=/auth" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services/albums-service/routes --data "name=albums-route" --data "paths[]=/albums" --data "strip_path=false" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services/reviews-service/routes --data "name=reviews-route" --data "paths[]=/reviews" --data "strip_path=false" > /dev/null
curl -s -X POST ${KONG_ADMIN_URL}/services/socials-service/routes --data "name=socials-route" --data "paths[]=/social" > /dev/null

echo "Kong Configuration Complete!"
PROXY_URL=$(minikube service kong -n shareyourtaste --url | head -1)
echo "Proxy URL: ${PROXY_URL}"
echo "Test: curl ${PROXY_URL}/albums/"
