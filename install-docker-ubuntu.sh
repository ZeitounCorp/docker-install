#!/usr/bin/env bash
set -euo pipefail

log() { printf "\n==> %s\n" "$*"; }
warn() { printf "\n!! %s\n" "$*" >&2; }

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    warn "Please run as root (recommended: sudo -E bash $0)"
    exit 1
  fi
}

is_ubuntu() {
  [[ -r /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]]
}

remove_conflicts() {
  log "Removing conflicting/unofficial packages (if present)"
  # Docker docs list these as conflicts on Ubuntu install.  [oai_citation:1‡Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)
  local pkgs=(docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc)
  # apt might error if none are installed; ignore.
  apt-get update -y
  apt-get remove -y $(dpkg --get-selections "${pkgs[@]}" 2>/dev/null | cut -f1) || true
}

setup_repo() {
  log "Installing prerequisites"
  apt-get update -y
  apt-get install -y ca-certificates curl

  log "Setting up Docker apt keyring and repository"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # shellcheck disable=SC1091
  . /etc/os-release
  local suite="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

  tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${suite}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt-get update -y
}

install_docker() {
  log "Installing Docker Engine + CLI + containerd + Buildx + Compose plugin"
  # Official package set for Ubuntu.  [oai_citation:2‡Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

enable_and_start() {
  log "Enabling + starting Docker service"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now docker || systemctl start docker
    systemctl --no-pager --full status docker || true
  else
    warn "systemctl not found; skipping service enable/start checks."
  fi
}

postinstall_optional_group() {
  # Docker docs note you need sudo unless your user is in the docker group.  [oai_citation:3‡Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)
  # Optional: set DOCKER_ADD_USER=1 to add the invoking user to the docker group.
  if [[ "${DOCKER_ADD_USER:-0}" == "1" ]]; then
    local u="${SUDO_USER:-}"
    if [[ -n "$u" && "$u" != "root" ]]; then
      log "Adding user '$u' to docker group (optional)"
      groupadd -f docker
      usermod -aG docker "$u"
      warn "User '$u' added to docker group. They must log out/in (or restart session) for it to take effect."
    else
      warn "No non-root SUDO_USER detected; cannot auto-add a user to docker group."
    fi
  fi
}

verify() {
  log "Verifying Docker installation"
  docker --version
  docker compose version || true

  log "Running hello-world test (requires network access)"
  # Official verification step.  [oai_citation:4‡Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)
  docker run --rm hello-world
}

main() {
  require_root
  if ! is_ubuntu; then
    warn "This script is intended for Ubuntu only."
    exit 1
  fi

  remove_conflicts
  setup_repo
  install_docker
  enable_and_start
  postinstall_optional_group
  verify

  log "Done."
}

main "$@"
