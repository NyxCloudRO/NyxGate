#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/opt/nyxgate"
RELEASES_DIR="${APP_ROOT}/releases"
VERSION_FILE="${APP_ROOT}/.release-version"
DOCKER_HUB_TAGS_URL="https://hub.docker.com/v2/namespaces/nyxmael/repositories/nyxgate/tags?page_size=100"
GITHUB_TARBALL_BASE="https://api.github.com/repos/NyxCloudRO/NyxGate/tarball"

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
  for cmd in curl tar gzip sort sed tr; do
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

prepare_release_checkout() {
  local version="$1"
  local release_dir="${RELEASES_DIR}/${version}"
  local source_dir="${release_dir}/src"
  local tarball_url="${GITHUB_TARBALL_BASE}/v${version}"

  mkdir -p "${source_dir}"

  if [[ ! -x "${source_dir}/deploy/upgrade.sh" ]]; then
    rm -rf "${source_dir}"
    mkdir -p "${source_dir}"
    curl -fsSL "${tarball_url}" | tar -xz --strip-components=1 -C "${source_dir}"
    chmod +x \
      "${source_dir}/install/install.sh" \
      "${source_dir}/install/upgrade.sh" \
      "${source_dir}/deploy/upgrade.sh" \
      "${source_dir}/deploy/backup.sh" \
      "${source_dir}/deploy/preflight.sh"
  fi

  printf '%s\n' "${source_dir}"
}

write_release_marker() {
  local version="$1"
  mkdir -p "${APP_ROOT}"
  printf '%s\n' "${version}" > "${VERSION_FILE}"
}

main() {
  require_root
  require_docker
  require_prerequisites

  mkdir -p "${APP_ROOT}" "${RELEASES_DIR}"

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

  local source_dir
  source_dir="$(prepare_release_checkout "${target_version}")"

  NYXGATE_TARGET_VERSION="${target_version}" "${source_dir}/deploy/upgrade.sh"
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
