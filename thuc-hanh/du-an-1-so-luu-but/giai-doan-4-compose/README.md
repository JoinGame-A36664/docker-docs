# Giai đoạn 4: Gom tất cả vào một file (Docker Compose)

## Ở giai đoạn này bạn học gì?
Chỉ **một ý**: thay cả đống lệnh dài của giai đoạn 3 bằng **một file `compose.yaml`**, rồi bật tắt cả hệ thống bằng **một lệnh**.

Hình dung: giai đoạn 3 là bạn đứng dặn thợ từng việc một. Giai đoạn 4 là bạn đưa cho thợ **bản kế hoạch có đủ mọi thứ**, thợ cứ thế làm.

Đọc thêm nếu thích: [Docker Compose](../../../docs/docker-coban/docker-compose.md).

## Làm theo

### Bước 1. Vào thư mục và tạo file cấu hình
```sh
cd thuc-hanh/du-an-1-so-luu-but/giai-doan-4-compose
cp .env.example .env            # PowerShell: Copy-Item .env.example .env
```

### Bước 2. Nhờ Compose kiểm tra file trước khi chạy
```sh
docker compose config
```
Lệnh này in ra file sau khi đã thay các `${...}` bằng giá trị thật. Nếu file viết sai (thụt lề lệch, thiếu dấu), nó báo lỗi **ngay tại đây**, đỡ phải chạy mới biết.

### Bước 3. Bật cả hệ thống
```sh
docker compose up -d --build
```
- `up` = dựng và chạy tất cả.
- `-d` = chạy ngầm.
- `--build` = đóng gói lại image trước khi chạy (đảm bảo luôn dùng code mới nhất).

### Bước 4. Xem tình trạng
```sh
docker compose ps
```
**Bạn sẽ thấy:** hai dòng `web` và `redis`. Đợi vài giây tới khi cột `STATUS` của cả hai có chữ `healthy` hoặc `Up`.

Mở `http://localhost:8080`: trang sổ lưu bút chạy như ở giai đoạn 3, nhưng lần này **không phải gõ lệnh nối mạng hay nối ổ lưu trữ nào cả**.

### Bước 5. Thử "tắt đi bật lại"
```sh
docker compose down        # tắt và xóa container, mạng (GIỮ lại ổ lưu dữ liệu)
docker compose up -d       # bật lại
```
Tải lại trang. **Bạn sẽ thấy:** lời nhắn và số lượt xem **vẫn còn** vì ổ `du-lieu-redis` vẫn giữ nguyên.

Thử tiếp, lần này xóa cả dữ liệu:
```sh
docker compose down -v     # thêm -v = xóa luôn các ổ lưu trữ
docker compose up -d
```
**Bạn sẽ thấy:** mọi thứ về số 0. Hãy nhớ: **`-v` nghĩa là mất dữ liệu.**

## Đọc hiểu file `compose.yaml` từng khối

Mở file `compose.yaml`. Trong file đã có ghi chú cho từng dòng; bảng dưới đây giúp bạn nhìn tổng thể. Mỗi lệnh `docker run` ở giai đoạn 3 chuyển thành một khối trong file như sau:

| Giai đoạn 3 (gõ tay) | Giai đoạn 4 (trong file) | Ghi chú |
|---|---|---|
| `docker network create mang-so-luu-but` | *(không cần viết)* | Compose tự tạo mạng riêng và nối mọi dịch vụ vào |
| `docker volume create du-lieu-redis` + `-v du-lieu-redis:/data` | khối `volumes:` ở cuối file + dòng `- du-lieu-redis:/data` trong redis | Khai báo ổ lưu trữ một lần, dùng ở chỗ cần |
| `docker run --name redis ... redis:7-alpine redis-server --appendonly yes` | khối `redis:` với `image`, `command`, `volumes` | |
| `docker build -t so-luu-but-web:1.0 ../ung-dung` | `build: ../ung-dung` + `image: so-luu-but-web:1.0` | Cả đóng gói lẫn đặt tên |
| `docker run --name web -e REDIS_HOST=redis -p 8000:8000 ...` | khối `web:` với `environment`, `ports` | |

### Cách đọc YAML trong 1 phút
```yaml
services:            # "services" là mục lớn
  web:               # trong services có một dịch vụ tên web (thụt vào 2 dấu cách)
    ports:           # trong web có mục ports
      - "8080:8000"  # dấu gạch đầu dòng = một mục trong danh sách
```
Thụt lề chính là **ý nghĩa** của file. Lệch một dấu cách là sai nghĩa. Vì vậy:
- Chỉ dùng **dấu cách**, không dùng phím Tab.
- Cùng cấp thì thụt bằng nhau.
- Gặp lỗi lạ khi `docker compose up`, việc đầu tiên là chạy `docker compose config` xem nó báo dòng nào.

### Giải thích những chỗ dễ vấp

| Dòng | Giải thích |
|---|---|
| `name: so-luu-but` | Tên cả hệ thống. Là tiền tố cho tên container (`so-luu-but-web-1`), mạng, ổ lưu trữ. Đổi tên thì Compose coi đây là một hệ thống khác |
| `build: ../ung-dung` | "Tự đóng gói image từ Dockerfile ở thư mục này." Đường dẫn tính **từ chỗ đặt file compose.yaml** |
| `ports: - "${HTTP_PORT:-8080}:8000"` | `${HTTP_PORT:-8080}` = lấy `HTTP_PORT` từ file `.env`, **không có thì dùng 8080**. Dấu ngoặc kép bao ngoài để YAML không hiểu nhầm dấu `:` |
| `environment: REDIS_HOST: redis` | Dặn ứng dụng gọi cuốn sổ tên `redis`. `redis` chính là tên dịch vụ bên dưới, nên chỉ cần ghi tên đó |
| `depends_on: redis: condition: service_healthy` | "Chờ redis khỏe rồi mới bật web." Cần có `healthcheck` ở redis thì điều kiện này mới có nghĩa |
| `restart: unless-stopped` | Tắt bất ngờ thì tự bật lại. Chỉ không bật lại khi **bạn** chủ động tắt |
| `command: ["redis-server", "--appendonly", "yes"]` | Lệnh khởi động, mỗi "từ" là một mục trong danh sách |
| `healthcheck: test: ["CMD", "redis-cli", "ping"]` | Cách hỏi thăm sức khỏe. `CMD` nghĩa là "chạy lệnh này bên trong container" |
| `interval / timeout / retries` | Hỏi mỗi 5 giây / chờ tối đa 3 giây / sai liên tiếp 10 lần mới coi là hỏng |
| `volumes:` (ở sát lề trái, cuối file) | Khai báo các ổ lưu trữ. Không khai báo ở đây mà dùng ở trên thì Compose báo lỗi |

## Tự kiểm tra
1. Muốn đổi cổng truy cập từ 8080 sang 9090 thì sửa ở đâu? *(Có thể không sửa file compose.yaml.)*
2. Vì sao lần này không cần lệnh `docker network create`?
3. Sau `docker compose down` dữ liệu còn, sau `docker compose down -v` thì mất. Vì sao?
4. Điều gì xảy ra nếu bạn xóa khối `healthcheck` của redis nhưng vẫn giữ `condition: service_healthy` trong web? *(Thử xem! Nhớ chạy `docker compose config` trước.)*

## Dọn dẹp trước khi sang giai đoạn sau
```sh
docker compose down -v
```

## Vấn đề còn lại, dẫn sang giai đoạn 5
Cổng của web mở **thẳng ra ngoài**. Web là chương trình viết cho dễ làm việc, không nên tiếp khách trực tiếp. Cách làm chuyên nghiệp là thêm một **"lễ tân" (nginx)** đứng trước, và giấu web, redis ra phía sau. Đó là [giai đoạn 5](../giai-doan-5-them-nginx/README.md).
