#!/usr/bin/env bash
set -euo pipefail

IMAGE="nyxmael/nyxgate:1.0.0"
CONTAINER_NAME="nyxgate"
DATA_DIR="/opt/nyxgate/data"

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "This upgrade must be run as root." >&2
    exit 1
  fi
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required before upgrading NyxGate." >&2
    exit 1
  fi
}

ensure_paths() {
  mkdir -p "/opt/nyxgate" "${DATA_DIR}"
}

upgrade_nyxgate() {
  docker pull "${IMAGE}"

  if docker ps -a --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
    docker stop "${CONTAINER_NAME}" >/dev/null || true
    docker rm "${CONTAINER_NAME}" >/dev/null || true
  fi

  docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p 8443:8443 \
    -v "${DATA_DIR}:/app/data" \
    "${IMAGE}" >/dev/null
}

main() {
  require_root
  require_docker
  ensure_paths
  upgrade_nyxgate

  cat <<EOF
========================================
NyxGate upgraded successfully
Your persistent data remains intact.
========================================
EOF
}

main "$@"
