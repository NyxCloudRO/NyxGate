#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/opt/nyxgate"
RELEASES_DIR="${APP_ROOT}/releases"
VERSION_FILE="${APP_ROOT}/.release-version"
DOCKER_HUB_TAGS_URL="https://hub.docker.com/v2/namespaces/nyxmael/repositories/nyxgate/tags?page_size=100"
GITHUB_TARBALL_BASE="https://api.github.com/repos/NyxCloudRO/NyxGate/tarball"

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
  apt-get install -y ca-certificates curl tar gzip coreutils
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
  require_supported_os
  ensure_prerequisites
  install_docker_if_missing

  mkdir -p "${APP_ROOT}" "${RELEASES_DIR}"

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

  local source_dir
  source_dir="$(prepare_release_checkout "${target_version}")"

  NYXGATE_TARGET_VERSION="${target_version}" "${source_dir}/deploy/upgrade.sh"
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
