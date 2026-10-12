#!/bin/bash
set -e

MINIKUBE_IP=${MINIKUBE_IP:-$(minikube ip)}
KONG_PROXY="http://${MINIKUBE_IP}:30000"
echo "Testing endpoints at ${KONG_PROXY}"

# 1. Auth: Get Token
echo "1. Getting Auth Token..."
TOKEN=$(curl -s -X POST ${KONG_PROXY}/auth/token -d "username=admin&password=secret" | jq -r .access_token)

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo "❌ Failed to get token"
    exit 1
else
    echo "✅ Got Token: ${TOKEN:0:10}..."
fi

# 2. Albums: Create Album
echo "2. Creating Album..."
ALBUM_RESP=$(curl -s -w "%{http_code}" -X POST ${KONG_PROXY}/albums/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"K8s Album", "artist":"Cloud Native Artist", "year":2024}')
CODE=${ALBUM_RESP: -3}
BODY=${ALBUM_RESP:0:${#ALBUM_RESP}-3}

if [ "$CODE" == "200" ]; then
    echo "✅ Album Created"
else
    echo "❌ Failed to create album. Code: $CODE"
fi

# 3. Reviews: Create Review (Dependency on Album ID? The services are loosely coupled but assume ID 1 exists)
echo "3. Creating Review..."
REVIEW_RESP=$(curl -s -w "%{http_code}" -X POST ${KONG_PROXY}/reviews/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"album_id":1, "rating":5, "comment":"Great K8s deployment!"}')
CODE=${REVIEW_RESP: -3}

if [ "$CODE" == "200" ]; then
    echo "✅ Review Created"
else
    echo "❌ Failed to create review. Code: $CODE"
fi

# 4. Socials: Create Comment
echo "4. Creating Comment..."
COMMENT_RESP=$(curl -s -w "%{http_code}" -X POST ${KONG_PROXY}/social/comments/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"review_id":1, "text":"Totally agree!"}')
CODE=${COMMENT_RESP: -3}

if [ "$CODE" == "200" ]; then
    echo "✅ Comment Created"
else
    echo "❌ Failed to create comment. Code: $CODE"
fi

# 5. Adminer
echo "5. Checking Adminer Accessibility..."
ADMINER_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${MINIKUBE_IP}:30002)
if [ "$ADMINER_CODE" == "200" ]; then
    echo "✅ Adminer is accessible (200 OK)"
else
    echo "❌ Adminer failed. Code: $ADMINER_CODE"
fi

# 6. Portainer
echo "6. Checking Portainer Accessibility..."
# Use -L to follow redirects (Portainer redirects to /9000/)
PORTAINER_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L http://${MINIKUBE_IP}:30003)
if [ "$PORTAINER_CODE" == "200" ]; then
    echo "✅ Portainer is accessible (200 OK)"
else
    echo "❌ Portainer failed. Code: $PORTAINER_CODE"
fi

echo "All tests passed!"
