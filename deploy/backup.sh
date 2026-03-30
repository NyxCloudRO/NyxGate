#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

ROOT_DIR="/opt/nyxgate"
CONFIG_DIR="${ROOT_DIR}/config"
CERTS_DIR="${ROOT_DIR}/certs"
SECRETS_DIR="${ROOT_DIR}/secrets"
BACKUP_DIR="${ROOT_DIR}/backups"
BACKUP_KEEP_COUNT="${NYXGATE_BACKUP_KEEP_COUNT:-3}"

mkdir -p "${BACKUP_DIR}"

if [[ -f "${CONFIG_DIR}/nyxgate.env" ]]; then
  # shellcheck disable=SC1091
  source "${CONFIG_DIR}/nyxgate.env"
fi
if [[ -f "${SECRETS_DIR}/nyxgate.secrets.env" ]]; then
  # shellcheck disable=SC1091
  source "${SECRETS_DIR}/nyxgate.secrets.env"
fi

DB_NAME="${NYXGATE_DB_NAME:-nyxgate}"
DB_USER="${NYXGATE_DB_USER:-nyxgate}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
STAMP_DIR="${BACKUP_DIR}/nyxgate-backup-${TS}"
mkdir -p "${STAMP_DIR}"

echo "[backup] creating database dump..."
if docker compose -f "${COMPOSE_FILE}" ps --services --filter status=running | grep -qx "nyxgate-postgres"; then
  docker compose -f "${COMPOSE_FILE}" exec -T nyxgate-postgres \
    pg_dump -U "${DB_USER}" -d "${DB_NAME}" -Fc > "${STAMP_DIR}/database.dump"
else
  echo "[backup] nyxgate-postgres is not running; skipping database dump." >&2
  : > "${STAMP_DIR}/database.dump"
fi

echo "[backup] archiving config/certs/secrets/data..."
tar -czf "${STAMP_DIR}/config.tgz" -C "${ROOT_DIR}" config
tar -czf "${STAMP_DIR}/certs.tgz" -C "${ROOT_DIR}" certs
tar -czf "${STAMP_DIR}/secrets.tgz" -C "${ROOT_DIR}" secrets
tar -czf "${STAMP_DIR}/data.tgz" -C "${ROOT_DIR}" data

cat > "${STAMP_DIR}/manifest.txt" <<EOF
created_at=${TS}
db_name=${DB_NAME}
db_user=${DB_USER}
files=database.dump,config.tgz,certs.tgz,secrets.tgz,data.tgz
EOF

if [[ "${BACKUP_KEEP_COUNT}" =~ ^[0-9]+$ ]] && (( BACKUP_KEEP_COUNT > 0 )); then
  mapfile -t OLD_BACKUPS < <(ls -1dt "${BACKUP_DIR}"/nyxgate-backup-* 2>/dev/null | tail -n +"$((BACKUP_KEEP_COUNT + 1))")
  if (( ${#OLD_BACKUPS[@]} > 0 )); then
    echo "[backup] pruning old backups, keeping newest ${BACKUP_KEEP_COUNT}..."
    rm -rf "${OLD_BACKUPS[@]}"
  fi
else
  echo "[backup] invalid NYXGATE_BACKUP_KEEP_COUNT=${BACKUP_KEEP_COUNT}; skipping retention pruning." >&2
fi

echo "[backup] completed: ${STAMP_DIR}"
