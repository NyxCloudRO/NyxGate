#!/usr/bin/env bash
set -euo pipefail

IMAGE="nyxmael/nyxgate:1.0.0"
CONTAINER_NAME="nyxgate"
APP_ROOT="/opt/nyxgate"
DATA_DIR="${APP_ROOT}/data"

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

detect_ip() {
  local ip
  ip="$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {for (i=1; i<=NF; i++) if ($i == "src") {print $(i+1); exit}}')"
  if [[ -z "${ip}" ]]; then
    ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  fi
  if [[ -z "${ip}" ]]; then
    ip="SERVER_IP"
  fi
  printf '%s\n' "${ip}"
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

prepare_directories() {
  mkdir -p "${APP_ROOT}" "${DATA_DIR}"
}

install_nyxgate() {
  docker pull "${IMAGE}"

  if docker ps -a --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
    docker rm -f "${CONTAINER_NAME}" >/dev/null
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
  require_supported_os
  install_docker_if_missing
  prepare_directories
  install_nyxgate

  local server_ip
  server_ip="$(detect_ip)"

  cat <<EOF
========================================
NyxGate installed successfully
Access your panel at:
https://${server_ip}:8443
========================================
EOF
}

main "$@"
