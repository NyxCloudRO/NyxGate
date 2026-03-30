#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

remove_path() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    rm -rf "${path}"
    echo "[prune] removed ${path}"
  fi
}

echo "[prune] removing orphaned local build artifacts..."
remove_path "${ROOT_DIR}/deploy/recovery-nginx/ui-dist"
remove_path "${ROOT_DIR}/agent/dist/nyxgate-agent"
remove_path "${ROOT_DIR}/ui/tsconfig.tsbuildinfo"

echo "[prune] done"
