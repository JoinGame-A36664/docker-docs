#!/bin/bash
# Cai dat Docker Engine + Buildx + Compose v2 tren Ubuntu 22.04 / 24.04 (cung chay duoc tren Debian 11/12)
# Cap nhat 2026: dung kho apt chinh thuc cua Docker, khong con dung apt-key va docker-compose 1.x
set -e

echo "== 1. Go cac goi cu (neu co) =="
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y $pkg 2>/dev/null || true
done

echo "== 2. Them kho apt chinh thuc cua Docker =="
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable"   | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "== 3. Cai Docker Engine, Buildx, Compose plugin =="
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "== 4. Khoi dong, cho phep user hien tai dung docker khong can sudo =="
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "== 5. Kiem tra =="
sudo docker --version
sudo docker compose version
sudo docker run --rm hello-world
echo "IMOK - hay dang xuat roi dang nhap lai de dung duoc lenh docker khong can sudo"
