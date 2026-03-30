#!/usr/bin/env bash
set -euo pipefail

echo "[prune] removing dangling images..."
docker image prune -f >/tmp/nyxgate-prune-images.log || true
cat /tmp/nyxgate-prune-images.log

echo "[prune] removing unused build cache..."
docker buildx prune -af >/tmp/nyxgate-prune-builder.log || true
cat /tmp/nyxgate-prune-builder.log

rm -f /tmp/nyxgate-prune-images.log /tmp/nyxgate-prune-builder.log
