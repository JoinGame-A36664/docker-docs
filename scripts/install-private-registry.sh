#!/bin/bash
# Deploy a private registry (registry:2 + nginx co TLS va basic auth)
# Cap nhat 2026: chay duoc tren Ubuntu/Debian va Rocky/Alma; dung network thay cho --link/links;
# bo "ssl on" (nginx moi khong con ho tro) va bo --privileged khong can thiet.
# Can co san: docker, va file gen-cer trong thu muc hien tai (xem scripts/gen-cer)
set -e

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y apache2-utils     # co lenh htpasswd
else
  sudo dnf install -y httpd-tools
fi

sudo rm -rf /docker-registry
sudo mkdir -p /docker-registry/data /docker-registry/nginx
cd /docker-registry/nginx
sudo htpasswd -b -c registry.password USERNAME PASSWORD      # DOI USERNAME / PASSWORD

sudo tee /docker-registry/nginx/registry.conf > /dev/null <<'EOF'
upstream docker-registry {
  server registry:5000;
}

server {
  listen 443 ssl;
  server_name myhub.docker.io;

  ssl_certificate     /etc/nginx/conf.d/myhub.docker.io.crt;
  ssl_certificate_key /etc/nginx/conf.d/myhub.docker.io.key;

  # tranh loi HTTP 413 khi push image lon
  client_max_body_size 0;
  chunked_transfer_encoding on;

  location /v2/ {
    auth_basic "registry.localhost";
    auth_basic_user_file /etc/nginx/conf.d/registry.password;
    add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

    proxy_pass                          http://docker-registry;
    proxy_set_header  Host              $http_host;
    proxy_set_header  X-Real-IP         $remote_addr;
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto $scheme;
    proxy_read_timeout                  900;
  }
}
EOF

# tao chung chi tu ky (lab) va chep vao thu muc nginx
sh ./gen-cer myhub.docker.io myhub.docker.io
sudo mv myhub.docker.io.* devdockerCA.* /docker-registry/nginx/

# network rieng de nginx goi registry theo ten "registry"
docker network create reg-net 2>/dev/null || true

docker run -d \
  --restart=always \
  --name registry \
  --network reg-net \
  --mount type=bind,source=/docker-registry/data,target=/data \
  --env REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
  registry:2

docker run -d \
  --restart=always \
  --name nginx \
  --network reg-net \
  --publish 443:443 \
  --mount type=bind,source=/docker-registry/nginx,target=/etc/nginx/conf.d,readonly \
  nginx:stable

echo "127.0.0.1   myhub.docker.io" | sudo tee -a /etc/hosts
echo "Thu: docker login myhub.docker.io  (can tin tuong CA tu ky, xem bai docker-deploy-private-registry.md)"
