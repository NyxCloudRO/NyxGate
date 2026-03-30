#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/opt/nyxgate"
CONFIG_DIR="${APP_ROOT}/config"
CERTS_DIR="${APP_ROOT}/certs"
SECRETS_DIR="${APP_ROOT}/secrets"
DATA_DIR="${APP_ROOT}/data"
BACKUP_DIR="${APP_ROOT}/backups"
VERSION_FILE="${APP_ROOT}/.release-version"
COMPOSE_FILE="${APP_ROOT}/docker-compose.yml"
DOCKER_HUB_TAGS_URL="https://hub.docker.com/v2/namespaces/nyxmael/repositories/nyxgate/tags?page_size=100"
APP_IMAGE_REPO="nyxmael/nyxgate"
POSTGRES_IMAGE="postgres:15-alpine"
REDIS_IMAGE="redis:7-alpine"

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

ensure_prerequisites() {
  apt-get update
  apt-get install -y ca-certificates curl tar gzip coreutils openssl python3
}

install_docker_if_missing() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    return
  fi

  apt-get install -y gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release && echo "${ID}")/gpg" -o /etc/apt/keyrings/docker.asc
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

latest_release_version() {
  python3 - "${DOCKER_HUB_TAGS_URL}" <<'PY'
import json
import re
import sys
import urllib.request

url = sys.argv[1]
tags = []

while url:
    with urllib.request.urlopen(url, timeout=20) as response:
        data = json.load(response)
    for row in data.get("results", []):
        name = str(row.get("name", "")).strip()
        if re.fullmatch(r"\d+(?:\.\d+)*", name):
            tags.append(name)
    url = data.get("next")

if not tags:
    sys.exit(1)

def version_key(value: str):
    return [int(part) for part in value.split(".")]

print(sorted(set(tags), key=version_key)[-1])
PY
}

current_release_version() {
  if [[ -f "${VERSION_FILE}" ]]; then
    head -n 1 "${VERSION_FILE}" | tr -d '[:space:]'
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -ks https://127.0.0.1:8443/ 2>/dev/null \
      | grep -o 'v[0-9][0-9.]*' \
      | head -n 1 \
      | tr -d 'v' \
      || true
    return 0
  fi

  return 0
}

version_compare() {
  local left="$1"
  local right="$2"
  if [[ "${left}" == "${right}" ]]; then
    printf '0\n'
    return 0
  fi
  if [[ "$(printf '%s\n%s\n' "${left}" "${right}" | sort -V | tail -n 1)" == "${left}" ]]; then
    printf '1\n'
    return 0
  fi
  printf '%s\n' '-1'
}

ensure_layout() {
  mkdir -p "${CONFIG_DIR}" "${CERTS_DIR}" "${SECRETS_DIR}" "${DATA_DIR}" "${BACKUP_DIR}"

  if [[ ! -f "${CONFIG_DIR}/nyxgate.env" ]]; then
    cat > "${CONFIG_DIR}/nyxgate.env" <<'EOF'
NYXGATE_DB_NAME=nyxgate
NYXGATE_DB_USER=nyxgate
NYXGATE_DB_PASSWORD=nyxgate
NYXGATE_DB_PORT=5432
NYXGATE_DB_SSLMODE=disable
POSTGRES_DB=nyxgate
POSTGRES_USER=nyxgate
POSTGRES_PASSWORD=nyxgate
NYXGATE_APP_MODE=production
NYXGATE_RETENTION_DAYS=30
NYXGATE_DASHBOARD_PORT=8443
NYXGATE_CERT_EXTRA_IPS=
EOF
    chmod 600 "${CONFIG_DIR}/nyxgate.env"
  fi

  if [[ ! -f "${SECRETS_DIR}/nyxgate.secrets.env" ]]; then
    cat > "${SECRETS_DIR}/nyxgate.secrets.env" <<EOF
NYXGATE_JWT_SECRET=$(openssl rand -hex 32)
EOF
    chmod 600 "${SECRETS_DIR}/nyxgate.secrets.env"
  fi
}

write_compose_file() {
  local version="$1"
  cat > "${COMPOSE_FILE}" <<EOF
services:
  nyxgate-postgres:
    image: ${POSTGRES_IMAGE}
    container_name: nyxgate-postgres
    restart: unless-stopped
    command: ["postgres", "-c", "listen_addresses=*"]
    env_file:
      - ${CONFIG_DIR}/nyxgate.env
      - ${SECRETS_DIR}/nyxgate.secrets.env
    expose:
      - "5432"
    volumes:
      - nyxgate-postgres-data:/var/lib/postgresql/data
    networks:
      - nyxgate-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \\"\$\${POSTGRES_USER}\\" -d \\"\$\${POSTGRES_DB}\\""]
      interval: 10s
      timeout: 5s
      retries: 8
      start_period: 15s

  nyxgate-redis:
    image: ${REDIS_IMAGE}
    container_name: nyxgate-redis
    restart: unless-stopped
    command: ["redis-server", "--appendonly", "yes", "--save", "60", "1"]
    expose:
      - "6379"
    volumes:
      - nyxgate-redis-data:/data
    networks:
      - nyxgate-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 8
      start_period: 10s

  nyxgate:
    image: ${APP_IMAGE_REPO}:${version}
    container_name: nyxgate
    restart: unless-stopped
    env_file:
      - ${CONFIG_DIR}/nyxgate.env
      - ${SECRETS_DIR}/nyxgate.secrets.env
    environment:
      NYXGATE_LISTEN_ADDR: ":8443"
      NYXGATE_DB_HOST: nyxgate-postgres
      NYXGATE_DB_PORT: "5432"
      NYXGATE_DB_SSLMODE: disable
      NYXGATE_REDIS_ADDR: nyxgate-redis:6379
      NYXGATE_CERT_DIR: /etc/nyxgate/certs
      NYXGATE_CERT_FILE: /etc/nyxgate/certs/tls.crt
      NYXGATE_KEY_FILE: /etc/nyxgate/certs/tls.key
    depends_on:
      nyxgate-postgres:
        condition: service_healthy
      nyxgate-redis:
        condition: service_healthy
    ports:
      - "8443:8443"
    volumes:
      - ${CERTS_DIR}:/etc/nyxgate/certs
      - ${CONFIG_DIR}:/etc/nyxgate/config
      - ${SECRETS_DIR}:/etc/nyxgate/secrets:ro
      - ${DATA_DIR}:/var/lib/nyxgate
    networks:
      - nyxgate-network
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- --no-check-certificate https://127.0.0.1:8443/api/setup/status >/dev/null"]
      interval: 10s
      timeout: 5s
      retries: 8
      start_period: 20s

volumes:
  nyxgate-postgres-data:
    external: true
    name: nyxgate-postgres-data
  nyxgate-redis-data:
    external: true
    name: nyxgate-redis-data

networks:
  nyxgate-network:
    name: nyxgate-network
EOF
}

migrate_legacy_postgres_volume() {
  docker volume create nyxgate-postgres-data >/dev/null
  docker volume create nyxgate-redis-data >/dev/null
  for legacy_vol in nyxgate_pg deploy_nyxgate_pg; do
    if docker volume ls -q | grep -qx "${legacy_vol}"; then
      local target_count
      target_count="$(docker run --rm -v nyxgate-postgres-data:/to alpine:3.20 sh -c 'ls -A /to | wc -l')"
      if [[ "${target_count}" == "0" ]]; then
        echo "[install] migrating legacy postgres volume ${legacy_vol} -> nyxgate-postgres-data"
        docker run --rm \
          -v "${legacy_vol}":/from \
          -v nyxgate-postgres-data:/to \
          alpine:3.20 sh -c 'cp -a /from/. /to/'
      fi
      break
    fi
  done
}

write_release_marker() {
  local version="$1"
  printf '%s\n' "${version}" > "${VERSION_FILE}"
}

main() {
  require_root
  require_supported_os
  ensure_prerequisites
  install_docker_if_missing
  ensure_layout

  local target_version
  target_version="$(latest_release_version)"
  if [[ -z "${target_version}" ]]; then
    echo "Unable to determine the latest published NyxGate release." >&2
    exit 1
  fi

  local current_version
  current_version="$(current_release_version)"
  if [[ -n "${current_version}" ]]; then
    case "$(version_compare "${current_version}" "${target_version}")" in
      0)
        cat <<EOF
========================================
NyxGate is already installed
Installed release: ${current_version}
Published release: ${target_version}
========================================
EOF
        exit 0
        ;;
      1)
        cat <<EOF
========================================
NyxGate install skipped
Installed release: ${current_version}
Published release: ${target_version}
The installed release is newer than the current Docker Hub tag.
========================================
EOF
        exit 0
        ;;
    esac
  fi

  write_compose_file "${target_version}"
  migrate_legacy_postgres_volume

  echo "[install] pulling published images..."
  docker compose -f "${COMPOSE_FILE}" pull

  echo "[install] starting NyxGate..."
  docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans

  echo "[install] validating service state..."
  docker compose -f "${COMPOSE_FILE}" ps

  write_release_marker "${target_version}"

  local server_ip
  server_ip="$(detect_ip)"

  cat <<EOF
========================================
NyxGate installed successfully
Installed release: ${target_version}
Access your panel at:
https://${server_ip}:8443
========================================
EOF
}

main "$@"
