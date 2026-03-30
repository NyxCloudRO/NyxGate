#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

declare -A CHECKS=()

mark_check() {
  local name="$1"
  CHECKS["$name"]=1
}

mark_checks_for_service() {
  local service="$1"
  case "$service" in
    nyxgate-api)
      mark_check controller
      mark_check agent
      ;;
    nyxgate-dashboard)
      mark_check ui
      ;;
    nyxgate-postgres|nyxgate-redis)
      ;;
    *)
      mark_check controller
      mark_check agent
      mark_check ui
      ;;
  esac
}

run_controller_checks() {
  echo "[preflight] running controller tests..."
  (
    cd "${REPO_ROOT}/controller"
    go test ./...
  )
}

run_agent_checks() {
  echo "[preflight] running agent tests..."
  (
    cd "${REPO_ROOT}/agent"
    go test ./cmd/nyxgate-agent/...
  )
}

run_ui_checks() {
  echo "[preflight] building ui..."
  (
    cd "${REPO_ROOT}/ui"
    npm run build
  )
}

if [[ "$#" -eq 0 ]]; then
  mark_check controller
  mark_check agent
  mark_check ui
else
  for service in "$@"; do
    mark_checks_for_service "$service"
  done
fi

if [[ -n "${CHECKS[controller]:-}" ]]; then
  run_controller_checks
fi

if [[ -n "${CHECKS[agent]:-}" ]]; then
  run_agent_checks
fi

if [[ -n "${CHECKS[ui]:-}" ]]; then
  run_ui_checks
fi

echo "[preflight] all requested checks passed"
