#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEPLOY_UPGRADE_SCRIPT="${REPO_ROOT}/deploy/upgrade.sh"
APP_ROOT="/opt/nyxgate"

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "This installer must be run as root." >&2
    exit 1
  fi
}

require_supported_os() {
  if [[ ! -r /etc/os-release ]]; then
    echo "Unable to detect operating system." >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian)
      ;;
    *)
      echo "Unsupported operating system. NyxGate install supports Ubuntu and Debian." >&2
      exit 1
      ;;
  esac
}

install_docker_if_missing() {
  if command -v docker >/dev/null 2>&1; then
    return
  fi

  apt-get update
  apt-get install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/"$(. /etc/os-release && echo "${ID}")"/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  local arch codename
  arch="$(dpkg --print-architecture)"
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
  echo \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$(. /etc/os-release && echo "${ID}") ${codename} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

require_compose_installer() {
  if [[ ! -x "${DEPLOY_UPGRADE_SCRIPT}" ]]; then
    echo "Compose installer not found at ${DEPLOY_UPGRADE_SCRIPT}." >&2
    echo "Use the deploy workflow from a full NyxGate checkout so Postgres and Redis data are preserved." >&2
    exit 1
  fi
}

prepare_directories() {
  mkdir -p "${APP_ROOT}"
}

install_nyxgate() {
  "${DEPLOY_UPGRADE_SCRIPT}"
}

main() {
  require_root
  require_supported_os
  install_docker_if_missing
  require_compose_installer
  prepare_directories
  install_nyxgate

  cat <<EOF
========================================
NyxGate installed successfully
Access your panel at:
https://SERVER_IP:8443
========================================
EOF
}

main "$@"
