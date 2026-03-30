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
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose support is required before upgrading NyxGate." >&2
    exit 1
  fi
}

require_prerequisites() {
  for cmd in curl tar gzip sort sed tr grep head; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "Required command not found: ${cmd}" >&2
      exit 1
    fi
  done
}

latest_release_version() {
  curl -fsSL "${DOCKER_HUB_TAGS_URL}" \
    | tr ',{}' '\n' \
    | sed -n 's/^"name":"\([0-9][0-9.]*\)"$/\1/p' \
    | sort -V \
    | tail -n 1
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
    image: postgres:16-alpine
    container_name: nyxgate-postgres
    restart: unless-stopped
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
    image: redis:7-alpine
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
    name: nyxgate-postgres-data
  nyxgate-redis-data:
    name: nyxgate-redis-data

networks:
  nyxgate-network:
    name: nyxgate-network
EOF
}

migrate_legacy_postgres_volume() {
  docker volume create nyxgate-postgres-data >/dev/null
  for legacy_vol in nyxgate_pg deploy_nyxgate_pg; do
    if docker volume ls -q | grep -qx "${legacy_vol}"; then
      local target_count
      target_count="$(docker run --rm -v nyxgate-postgres-data:/to alpine:3.20 sh -c 'ls -A /to | wc -l')"
      if [[ "${target_count}" == "0" ]]; then
        echo "[upgrade] migrating legacy postgres volume ${legacy_vol} -> nyxgate-postgres-data"
        docker run --rm \
          -v "${legacy_vol}":/from \
          -v nyxgate-postgres-data:/to \
          alpine:3.20 sh -c 'cp -a /from/. /to/'
      fi
      break
    fi
  done
}

create_backup() {
  local ts stamp_dir
  ts="$(date -u +%Y%m%dT%H%M%SZ)"
  stamp_dir="${BACKUP_DIR}/nyxgate-backup-${ts}"
  mkdir -p "${stamp_dir}"

  if [[ -f "${CONFIG_DIR}/nyxgate.env" ]]; then
    # shellcheck disable=SC1091
    source "${CONFIG_DIR}/nyxgate.env"
  fi

  local db_name="${NYXGATE_DB_NAME:-nyxgate}"
  local db_user="${NYXGATE_DB_USER:-nyxgate}"

  echo "[backup] creating database dump..."
  if docker compose -f "${COMPOSE_FILE}" ps --services --filter status=running | grep -qx "nyxgate-postgres"; then
    docker compose -f "${COMPOSE_FILE}" exec -T nyxgate-postgres \
      pg_dump -U "${db_user}" -d "${db_name}" -Fc > "${stamp_dir}/database.dump"
  else
    : > "${stamp_dir}/database.dump"
  fi

  echo "[backup] archiving persistent data..."
  tar -czf "${stamp_dir}/config.tgz" -C "${APP_ROOT}" config
  tar -czf "${stamp_dir}/certs.tgz" -C "${APP_ROOT}" certs
  tar -czf "${stamp_dir}/secrets.tgz" -C "${APP_ROOT}" secrets
  tar -czf "${stamp_dir}/data.tgz" -C "${APP_ROOT}" data

  cat > "${stamp_dir}/manifest.txt" <<EOF
created_at=${ts}
db_name=${db_name}
db_user=${db_user}
files=database.dump,config.tgz,certs.tgz,secrets.tgz,data.tgz
EOF

  echo "[backup] completed: ${stamp_dir}"
}

write_release_marker() {
  local version="$1"
  printf '%s\n' "${version}" > "${VERSION_FILE}"
}

main() {
  require_root
  require_docker
  require_prerequisites
  ensure_layout

  local current_version target_version
  current_version="$(current_release_version)"
  target_version="$(latest_release_version)"

  if [[ -z "${target_version}" ]]; then
    echo "Unable to determine the latest published NyxGate release." >&2
    exit 1
  fi

  if [[ -n "${current_version}" ]] && [[ "${current_version}" == "${target_version}" ]]; then
    cat <<EOF
========================================
NyxGate is already up to date
Installed release: ${current_version}
Published release: ${target_version}
========================================
EOF
    exit 0
  fi

  if [[ -n "${current_version}" ]] && [[ "$(version_compare "${current_version}" "${target_version}")" == "1" ]]; then
    cat <<EOF
========================================
NyxGate upgrade skipped
Installed release: ${current_version}
Published release: ${target_version}
The installed release is newer than the current Docker Hub tag.
========================================
EOF
    exit 0
  fi

  write_compose_file "${target_version}"
  migrate_legacy_postgres_volume
  create_backup

  echo "[upgrade] pulling published images..."
  docker compose -f "${COMPOSE_FILE}" pull

  echo "[upgrade] recreating services with preserved data..."
  docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans

  echo "[upgrade] validating service state..."
  docker compose -f "${COMPOSE_FILE}" ps

  write_release_marker "${target_version}"

  cat <<EOF
========================================
NyxGate upgraded successfully
Previous release: ${current_version:-unknown}
Installed release: ${target_version}
Persistent platform data was preserved.
========================================
EOF
}

main "$@"
