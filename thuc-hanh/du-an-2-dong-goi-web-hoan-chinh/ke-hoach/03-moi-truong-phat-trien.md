# Bước 3: Môi trường phát triển (vừa sửa code vừa thấy ngay)

## Mục tiêu
Khi đang viết code, bạn muốn **sửa xong là thấy kết quả**, không muốn đóng gói lại mỗi lần. Đồng thời vẫn dùng **đúng các thành phần** như khi chạy thật (cùng PostgreSQL, cùng nginx), để tránh kiểu "chạy được trên máy tôi mà lên máy chủ thì hỏng".

## Ý tưởng: chồng hai file lên nhau
Thay vì viết hai file giống nhau 90%, ta có:
- `compose.yaml`: cách chạy **thật** (đầy đủ).
- `compose.dev.yaml`: **chỉ những chỗ khác** khi phát triển.

Chạy cả hai cùng lúc, file sau chồng lên file trước:
```sh
docker compose -f compose.yaml -f compose.dev.yaml up -d --build
```
Quy tắc chồng: mục trùng tên thì **file sau thắng**; danh sách (như `ports`, `volumes`) thì **được cộng thêm**.

## Làm gì

### 3.1 Chuẩn bị (nếu chưa làm)
```sh
cp .env.example .env
sh bi-mat/tao-bi-mat.sh            # PowerShell: ./bi-mat/tao-bi-mat.ps1
```

### 3.2 Chạy ở chế độ phát triển
```sh
docker compose -f compose.yaml -f compose.dev.yaml up -d --build
docker compose -f compose.yaml -f compose.dev.yaml ps
```
Mở `http://localhost:8080`.

### 3.3 Thử "sửa là thấy"
- **Giao diện:** mở `ung-dung/frontend/public/style.css`, đổi `#2563eb` (màu nút) thành màu khác, lưu, tải lại trình duyệt. Thấy ngay, không cần đóng gói.
- **API:** mở `ung-dung/api/app.py`, trong hàm `suc_khoe` đổi `status="ok"` thành `status="tot"`, lưu. Sau vài giây gunicorn tự nạp lại. Kiểm tra: `curl http://localhost:8080/api/health`. Nhớ đổi lại.
- **Xem nhật ký khi đang làm:** `docker compose -f compose.yaml -f compose.dev.yaml logs -f api`

### 3.4 Xem dữ liệu trong cơ sở dữ liệu
Chế độ phát triển mở cổng `5432` **chỉ cho máy bạn** (`127.0.0.1`). Có hai cách xem:
```sh
# Cách 1: dùng công cụ có sẵn trong container (không cần cài gì)
docker compose -f compose.yaml -f compose.dev.yaml exec db psql -U app -d appdb -c "SELECT * FROM tasks;"

# Cách 2: dùng phần mềm trên máy (DBeaver, pgAdmin, TablePlus...)
#   Máy chủ: localhost   Cổng: 5432   Cơ sở dữ liệu: appdb   Người dùng: app
#   Mật khẩu: nội dung file bi-mat/db_password.txt
```

### 3.5 Làm cho gõ lệnh ngắn lại (tùy chọn)
Gõ `-f compose.yaml -f compose.dev.yaml` mỗi lần rất mệt. Có hai cách:
- Đặt biến một lần trong phiên làm việc: `export COMPOSE_FILE=compose.yaml:compose.dev.yaml` (bash) hoặc `$env:COMPOSE_FILE="compose.yaml;compose.dev.yaml"` (PowerShell). Từ đó chỉ cần gõ `docker compose up -d`.
- Hoặc đặt dòng `COMPOSE_FILE=compose.yaml:compose.dev.yaml` vào file `.env` **trên máy phát triển** (Windows dùng dấu `;` thay cho `:`). Đừng đặt dòng này trên máy chủ thật.

## Đọc hiểu `compose.dev.yaml`
| Phần trong file | Nghĩa dễ hiểu |
|---|---|
| `web: volumes: - ./ung-dung/frontend/public:/usr/share/nginx/html:ro` | Gắn thư mục giao diện của bạn thẳng vào nginx, thay cho bản đã chép trong image. Sửa file là thấy |
| `api: volumes: - ./ung-dung/api/app.py:/app/app.py:ro` | Như trên, cho code API |
| `api: command: [... "--reload" ...]` | Thay lệnh khởi động bằng lệnh có `--reload`: file đổi là gunicorn tự nạp lại |
| `db: ports: - "127.0.0.1:5432:5432"` | Mở cổng cơ sở dữ liệu, nhưng chỉ cho chính máy bạn |

## Kiểm tra (bạn đã xong bước 3 khi…)
- [ ] Trang chạy và có 3 việc mẫu.
- [ ] Sửa màu nút → thấy đổi mà không đóng gói lại.
- [ ] Xem được bảng `tasks` bằng `psql` hoặc công cụ trên máy.
- [ ] Bạn giải thích được vì sao `compose.dev.yaml` ngắn hơn nhiều so với `compose.yaml`.

## Bài tập
1. Thêm một cột `ghi_chu` kiểu `TEXT` vào bảng `tasks` **trên máy phát triển**. Chú ý: file `init.sql` chỉ chạy lần đầu, nên bạn phải dùng `psql` chạy `ALTER TABLE ...`. Vì sao đây là vấn đề khi lên máy chủ thật? (Gợi ý: bước 9.)
2. Tắt rồi bật lại bằng `down` / `up -d`: dữ liệu còn không? Còn nếu dùng `down -v` thì sao?

Tiếp theo: [Bước 4: Môi trường chạy thật](04-moi-truong-chay-that.md)
