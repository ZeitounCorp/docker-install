# docker-install

Automation-friendly **Docker Engine installer for Ubuntu** following the **official Docker documentation**.

Built for fast server provisioning where Docker is a core dependency. Designed to be safely used via **`curl | bash`** while remaining explicit, verifiable, and idempotent.

---

## Features

- ✅ Installs **Docker Engine** using Docker’s **official APT repository**
- ✅ Removes conflicting/unofficial Docker packages
- ✅ Installs:
  - `docker-ce`
  - `docker-ce-cli`
  - `containerd.io`
  - Docker Buildx plugin
  - Docker Compose plugin
- ✅ Enables & starts Docker via `systemd`
- ✅ Verifies installation with `hello-world`
- ✅ Optional: add invoking user to the `docker` group
- ✅ Non-interactive friendly (ideal for servers, cloud-init, CI)

---

## Supported OS

- **Ubuntu only**
  - Tested with 20.04, 22.04, 24.04+
  - Uses `/etc/apt/keyrings/docker.asc` and `docker.sources`

---

## Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ZeitounCorp/docker-install/main/install-docker-ubuntu.sh | sudo -E bash
```

This will:
1. Configure Docker’s official APT repository
2. Install Docker Engine and required plugins
3. Enable and start the Docker service
4. Run a verification container

---

## Optional: Add User to `docker` Group

By default, Docker requires `sudo`.

To allow the invoking user to run Docker without sudo:

```bash
curl -fsSL https://raw.githubusercontent.com/ZeitounCorp/docker-install/main/install-docker-ubuntu.sh |   sudo -E env DOCKER_ADD_USER=1 bash
```

> ⚠️ The user must **log out and back in** for group changes to apply.

---

## Environment Variables

| Variable | Description | Default |
|--------|-------------|---------|
| `DOCKER_ADD_USER` | Add invoking user to `docker` group (`1` or `0`) | `0` |

---

## What the Script Does

### 1. Removes Conflicting Packages

Removes any unofficial or conflicting Docker-related packages:
- `docker.io`
- `docker-compose`
- `podman-docker`
- `containerd`
- `runc`

(as recommended by Docker docs)

---

### 2. Sets Up Official Docker Repository

- Adds Docker GPG key to `/etc/apt/keyrings/docker.asc`
- Creates `/etc/apt/sources.list.d/docker.sources`
- Uses the correct Ubuntu codename automatically

---

### 3. Installs Official Packages

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

---

### 4. Enables & Verifies Docker

- Enables Docker at boot
- Starts the service
- Runs:

```bash
docker run hello-world
```

---

## Verification

After installation:

```bash
docker --version
docker compose version
docker run hello-world
```

---

## Security Notes

- Uses **only Docker’s official installation method**
- No third-party scripts or mirrors
- Recommended best practices:
  - Pin script to a specific commit or tag
  - Review script before running as root
  - Vendor internally for production environments

---

## Example: Server Bootstrap

```bash
#!/usr/bin/env bash
set -e

curl -fsSL https://raw.githubusercontent.com/ZeitounCorp/docker-install/main/install-docker-ubuntu.sh | sudo -E bash
```

---

## License

MIT

---

## Maintainer

**ZeitounCorp**  
https://github.com/ZeitounCorp
