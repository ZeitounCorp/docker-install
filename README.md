# docker-install
Simple Script to auto-install Docker on newly setup Linux

# How to use it
> Basic install as described on Docker [Installation Instructions](https://docs.docker.com/engine/install/ubuntu/)
```bash
curl -fsSL https://raw.githubusercontent.com/ZeitounCorp/docker-install/main/install-docker-ubuntu.sh | sudo -E bash
```
> Optional: also add the invoking sudo user to the docker group:
```bash
curl -fsSL https://raw.githubusercontent.com/ZeitounCorp/docker-install/main/install-docker-ubuntu.sh | sudo -E env DOCKER_ADD_USER=1 bash
```
