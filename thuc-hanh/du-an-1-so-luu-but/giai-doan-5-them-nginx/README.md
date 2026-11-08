# Giai đoạn 5: Thêm "lễ tân" nginx và chia mạng thành hai khu

## Ở giai đoạn này bạn học gì?
Hai ý, đi cùng nhau:
1. **Reverse proxy (nginx làm lễ tân):** người ngoài chỉ gặp nginx. Nginx chuyển yêu cầu vào cho web.
2. **Chia mạng thành khu ngoài và khu trong:** cái gì không cần cho người ngoài thấy thì giấu vào khu trong.

Ví dụ đời thường: một tòa nhà văn phòng. Khách chỉ gặp **lễ tân** ở sảnh (khu ngoài). **Phòng làm việc** (web) và **phòng hồ sơ** (redis) nằm bên trong. Lễ tân dẫn khách vào phòng làm việc, nhưng khách không thể tự đi thẳng vào phòng hồ sơ.

Đọc thêm nếu thích: [Network trong Docker](../../../docs/docker-coban/05-network/docker-network.md) (nhất là mục "Lưu ý bảo mật: Docker và tường lửa").

## Làm theo

### Bước 1. Vào thư mục và tạo file cấu hình
```sh
cd thuc-hanh/du-an-1-so-luu-but/giai-doan-5-them-nginx
cp .env.example .env            # PowerShell: Copy-Item .env.example .env
```

### Bước 2. Kiểm tra rồi chạy
```sh
docker compose config
docker compose up -d --build
docker compose ps
```
**Bạn sẽ thấy:** ba dịch vụ `nginx`, `web`, `redis`. Chờ tới khi `web` và `redis` có `healthy`.

### Bước 3. Mở trang qua nginx
Vào `http://localhost:8080`. Trang chạy như trước. Tải lại nhiều lần và để ý dòng **"Container phục vụ"** (đó là mã của container `web`).

### Bước 4. Kiểm chứng "web đã được giấu"
Thử vào thẳng web ở cổng 8000: `http://localhost:8000`.

**Bạn sẽ thấy:** không vào được. Vì `web` giờ không có cánh cửa nào thông ra máy bạn. Chỉ nginx có.

### Bước 5. Kiểm chứng "chia khu ngoài và khu trong"
```sh
# web nằm ở cả hai khu nên tìm thấy redis. Lệnh in ra một địa chỉ IP:
docker compose exec web python -c "import socket; print(socket.gethostbyname('redis'))"

# nginx chỉ ở khu ngoài nên KHÔNG tìm thấy redis. Lệnh báo lỗi là ĐÚNG:
docker compose exec nginx nslookup redis
```
Nghĩa là nếu kẻ xấu chiếm được nginx, nó cũng **không có đường nào tới redis**.

## Đọc hiểu phần MỚI trong `compose.yaml`

So với giai đoạn 4, file này chỉ thêm và đổi mấy chỗ. Mỗi chỗ đều có ghi chú trong file; bảng dưới tóm tắt.

| Chỗ | Là gì | Giải thích dễ hiểu |
|---|---|---|
| Khối `nginx:` (mới) | Dịch vụ lễ tân | Dùng image nginx có sẵn, không phải đóng gói gì |
| `nginx` → `ports: "${HTTP_PORT:-8080}:80"` | Cánh cửa duy nhất ra ngoài | Cổng 8080 trên máy bạn thông vào cổng 80 của nginx |
| `nginx` → `volumes: ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro` | Đưa file cấu hình vào nginx | Trái là file trên máy bạn, phải là chỗ nginx đọc, `:ro` là chỉ đọc |
| `web` → (bỏ `ports`) | Giấu web đi | Không có mục `ports` nghĩa là không có cửa nào ra ngoài |
| `web` → `networks: - khu-ngoai - khu-trong` | Web nằm ở cả hai khu | Để nginx gọi được web **và** web gọi được redis |
| `redis` → `networks: - khu-trong` | Redis chỉ ở khu trong | Chỉ web gọi được redis |
| Khối `networks:` cuối file | Khai báo hai mạng | Giống như khai báo `volumes` ở giai đoạn 4 |
| `depends_on: web: condition: service_healthy` (trong nginx) | Chờ web khỏe | Chuỗi chờ: redis khỏe → web bật → web khỏe → nginx bật |

### File `nginx/default.conf`
Không phải YAML, là cấu hình riêng của nginx. File có ghi chú từng dòng. Ý chính chỉ một dòng: **`proxy_pass http://web:8000;`** nghĩa là *"mọi yêu cầu đến, chuyển vào dịch vụ tên `web`, cổng 8000"*. Chữ `web` ở đây là tên dịch vụ trong `compose.yaml`, Docker tự đổi ra địa chỉ.

## Tự kiểm tra
1. Nếu kẻ xấu chiếm được container nginx, nó có nối thẳng tới redis được không? Vì sao?
2. Vì sao nên để `redis` **không có** mục `ports`?
3. Nếu viết sai tên trong `proxy_pass http://web:8000;` thành `http://trangweb:8000;` thì chuyện gì xảy ra? *(Thử xem! Sửa file rồi chạy `docker compose restart nginx`, xem `docker compose logs nginx`. Nhớ sửa lại cho đúng.)*

## Dọn dẹp
Không cần dọn gì để sang giai đoạn 6, vì giai đoạn 6 dùng chính hệ thống này. Nếu muốn dọn: `docker compose down -v`.

## Vấn đề còn lại, dẫn sang giai đoạn 6
Hệ thống đã chạy và khá an toàn. Còn thiếu: cách **theo dõi khi có chuyện**, **giới hạn để một container không ăn hết máy**, **sửa code là thấy ngay**, và **dọn dẹp sạch sẽ**. Đó là [giai đoạn 6](../giai-doan-6-van-hanh/README.md).
