#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEPLOY_UPGRADE_SCRIPT="${REPO_ROOT}/deploy/upgrade.sh"

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

require_compose_upgrade() {
  if [[ ! -x "${DEPLOY_UPGRADE_SCRIPT}" ]]; then
    echo "Compose upgrade script not found at ${DEPLOY_UPGRADE_SCRIPT}." >&2
    echo "Use the deploy workflow from a full NyxGate checkout so the existing database and Redis state stay attached." >&2
    exit 1
  fi
}

upgrade_nyxgate() {
  "${DEPLOY_UPGRADE_SCRIPT}"
}

main() {
  require_root
  require_docker
  require_compose_upgrade
  upgrade_nyxgate

  cat <<EOF
========================================
NyxGate upgraded successfully
Persistent data was preserved through the compose upgrade path.
========================================
EOF
}

main "$@"
