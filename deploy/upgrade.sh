#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

ROOT_DIR="/opt/nyxgate"
CONFIG_DIR="${ROOT_DIR}/config"
CERTS_DIR="${ROOT_DIR}/certs"
SECRETS_DIR="${ROOT_DIR}/secrets"
DATA_DIR="${ROOT_DIR}/data"
BACKUP_SCRIPT="${SCRIPT_DIR}/backup.sh"
PREFLIGHT_SCRIPT="${SCRIPT_DIR}/preflight.sh"

mkdir -p "${CONFIG_DIR}" "${CERTS_DIR}" "${SECRETS_DIR}" "${DATA_DIR}" "${ROOT_DIR}/backups"

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
  JWT_SECRET="$(openssl rand -hex 32)"
  cat > "${SECRETS_DIR}/nyxgate.secrets.env" <<EOF
NYXGATE_JWT_SECRET=${JWT_SECRET}
EOF
  chmod 600 "${SECRETS_DIR}/nyxgate.secrets.env"
fi

docker volume create nyxgate-postgres-data >/dev/null
docker volume create nyxgate-redis-data >/dev/null
for LEGACY_VOL in nyxgate_pg deploy_nyxgate_pg; do
  if docker volume ls -q | grep -qx "${LEGACY_VOL}"; then
    TARGET_COUNT="$(docker run --rm -v nyxgate-postgres-data:/to alpine:3.20 sh -c 'ls -A /to | wc -l')"
    if [[ "${TARGET_COUNT}" == "0" ]]; then
      echo "[upgrade] migrating legacy postgres volume ${LEGACY_VOL} -> nyxgate-postgres-data"
      docker run --rm \
        -v "${LEGACY_VOL}":/from \
        -v nyxgate-postgres-data:/to \
        alpine:3.20 sh -c 'cp -a /from/. /to/'
    fi
    break
  fi
done

echo "[upgrade] running preflight checks..."
"${PREFLIGHT_SCRIPT}"

echo "[upgrade] creating pre-upgrade backup..."
"${BACKUP_SCRIPT}"

echo "[upgrade] pulling base images..."
docker compose -f "${COMPOSE_FILE}" pull nyxgate-postgres || true

echo "[upgrade] building NyxGate images..."
docker compose -f "${COMPOSE_FILE}" build --pull nyxgate-dashboard nyxgate-api

echo "[upgrade] recreating services (data preserved)..."
docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans

echo "[upgrade] validating service state..."
docker compose -f "${COMPOSE_FILE}" ps

echo "[upgrade] completed"
echo "[upgrade] WARNING: never run 'docker compose down -v' in production."
