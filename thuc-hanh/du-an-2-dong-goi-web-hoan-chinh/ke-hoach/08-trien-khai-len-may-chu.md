# Bước 8: Đưa lên máy chủ

## Mục tiêu
Đưa hệ thống từ máy bạn lên một máy chủ thật (VPS của nhà cung cấp, máy chủ công ty...) để người khác truy cập qua Internet. Bước này chủ yếu là **chuẩn bị và kiểm tra**; phần Docker thì bạn đã có sẵn.

> Dự án này cho bạn sẵn mọi thứ đến cổng HTTP. Phần **HTTPS (ổ khóa xanh)** nói ở mục 8.6 là việc cần làm tiếp, chưa có mã sẵn trong dự án.

## Làm gì

### 8.1 Chọn máy chủ
- Hệ điều hành: **Ubuntu Server 22.04 hoặc 24.04** (hoặc Debian 12).
- Cấu hình gợi ý để thử: 1 đến 2 CPU, 2 GB RAM, 20 GB ổ cứng.
- Bạn có quyền `sudo` và đăng nhập được bằng SSH.

### 8.2 Cài Docker lên máy chủ
Dùng script `scripts/install-docker.sh` nằm ở gốc repo này. Máy chủ chưa có code nên hãy chép nó lên (ví dụ `scp scripts/install-docker.sh nguoidung@IP-may-chu:~`) rồi chạy `sh install-docker.sh`. Hoặc làm tay từng lệnh theo bài [Cài đặt docker](../../../docs/docker-5m/01.Caidatdocker.md). Sau đó đăng xuất rồi đăng nhập lại và kiểm tra:
```sh
docker --version
docker compose version
```

### 8.3 Tường lửa: chỉ mở những cổng cần thiết
Trên Ubuntu với `ufw`:
```sh
sudo ufw allow OpenSSH        # giữ lại cổng SSH để khỏi tự khóa mình ngoài máy chủ
sudo ufw allow 80/tcp         # web (HTTP)
sudo ufw allow 443/tcp        # sau này dùng cho HTTPS
sudo ufw enable
```
**Bẫy quan trọng:** Docker tự thêm luật riêng và **đi trước `ufw`**. Cổng nào bạn đã `ports:` trong Compose đều có thể mở ra Internet dù `ufw` chặn. Vì vậy dự án chỉ cho `web` có `ports:`, và `db` không bao giờ có. Đọc thêm mục "Lưu ý bảo mật: Docker và tường lửa" trong bài [Network](../../../docs/docker-coban/05-network/docker-network.md).

### 8.4 Đưa dự án lên máy chủ
Có hai cách. Cách A đơn giản nhất cho người mới:

**Cách A: lấy code về rồi đóng gói ngay trên máy chủ**
```sh
git clone <địa-chỉ-repo-của-bạn> du-an
cd du-an/thuc-hanh/du-an-2-dong-goi-web-hoan-chinh
cp .env.example .env
nano .env                         # đặt HTTP_PORT=80 và APP_VERSION
sh bi-mat/tao-bi-mat.sh
docker compose up -d --build
```

**Cách B: máy chủ chỉ tải image đã đóng gói sẵn (cách làm của dự án thật)**
Image đã được CI đóng gói và đẩy lên `ghcr.io` (bước 7). Máy chủ không cần mã nguồn của `ung-dung/`, chỉ cần `compose.yaml`, `.env`, `ung-dung/db/init.sql`, và thư mục `bi-mat/`:
```sh
docker login ghcr.io -u <tên-github> # dùng Personal Access Token có quyền read:packages khi được hỏi mật khẩu
# trong .env:  IMAGE_PREFIX=ghcr.io/ten-ban/ten-repo-    APP_VERSION=1.0.0   (chữ thường)
docker compose pull
docker compose up -d --no-build
```
(Tên image phải khớp với cách CI đặt tên: `ghcr.io/<repo>-api`, `ghcr.io/<repo>-frontend`. Nếu khác, chỉnh `image:` trong `compose.yaml` cho đúng.)

### 8.5 Kiểm tra sau khi bật
```sh
docker compose ps                         # cả 3 dịch vụ phải "healthy"
curl -i http://localhost/api/health       # trên máy chủ
```
Rồi từ **một máy khác** mở `http://<địa-chỉ-IP-máy-chủ>`. Thấy trang là được.

Kiểm tra "db không lộ ra ngoài": từ máy khác thử kết nối cổng `5432` của máy chủ, phải **không** vào được:
```sh
nc -vz <địa-chỉ-IP-máy-chủ> 5432          # kết quả mong đợi: bị từ chối / hết thời gian
```

### 8.6 Việc cần làm tiếp: tên miền và HTTPS
Người dùng thật mong muốn `https://ten-cua-ban.vn`. Các bước:
1. **Mua tên miền** và trỏ bản ghi `A` về địa chỉ IP máy chủ.
2. **Bật HTTPS**: HTTPS cần một chứng chỉ. Có ba hướng thông dụng:
   - Đặt thêm một "lễ tân thứ hai" phía trước `web` có khả năng tự xin và gia hạn chứng chỉ miễn phí (ví dụ **Caddy**, hoặc **nginx + certbot**, hoặc **Traefik**).
   - Dùng dịch vụ phía trước như **Cloudflare** để họ lo HTTPS cho bạn.
   - Dùng dịch vụ đám mây có sẵn bộ cân bằng tải với HTTPS.
3. Khi đó chỉ "lễ tân mới" mở cổng 80 và 443; `web` cũ trở về chỉ nói chuyện nội bộ (bỏ `ports:` của nó).

Đây là bước mở rộng tiếp theo mà bạn nên tự làm sau khi hiểu dự án.

## Danh sách kiểm tra trước khi cho người dùng vào
- [ ] Docker + Compose đã cài, user chạy được `docker` không cần `sudo`.
- [ ] Tường lửa chỉ mở SSH, 80, 443.
- [ ] `.env` có `HTTP_PORT=80`, `APP_VERSION` đúng.
- [ ] `bi-mat/db_password.txt` đã tạo trên máy chủ, **không** copy từ máy phát triển.
- [ ] Cả 3 dịch vụ `healthy`.
- [ ] Cổng `5432` **không** truy cập được từ bên ngoài.
- [ ] Đã sao lưu thử một lần và đã thử khôi phục (bước 6).
- [ ] Đã đặt lịch sao lưu tự động.
- [ ] Máy chủ tự bật Docker khi khởi động lại: `sudo systemctl is-enabled docker` phải ra `enabled`.

## Kiểm tra (bạn đã xong bước 8 khi…)
- [ ] Người khác truy cập được trang qua IP (hoặc tên miền) của máy chủ.
- [ ] Bạn khởi động lại máy chủ (`sudo reboot`) và hệ thống **tự trở lại** nhờ `restart: unless-stopped`.

## Bài tập
Nếu không có máy chủ thật, dùng một máy ảo (VirtualBox, WSL 2 với Ubuntu, hoặc máy chủ thử nghiệm của nhà cung cấp đám mây) làm "máy chủ" và làm đủ các bước 8.2 đến 8.5. Kết quả học được tương đương.

Tiếp theo: [Bước 9: Vận hành và cập nhật](09-van-hanh-va-cap-nhat.md)
