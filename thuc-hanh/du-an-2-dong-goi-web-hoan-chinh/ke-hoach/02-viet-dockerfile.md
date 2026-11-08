# Bước 2: Viết Dockerfile cho từng phần

## Mục tiêu
Mỗi phần có **một image riêng**: nhỏ, sạch, chạy bằng tài khoản thường, tự báo được mình khỏe hay không. Cơ sở dữ liệu dùng image PostgreSQL có sẵn nên **không cần viết Dockerfile**, chỉ cần cấu hình.

## Làm gì

### 2.1 Dockerfile của API: `ung-dung/api/Dockerfile`
File có ghi chú từng dòng. Bức tranh lớn: nó có **hai giai đoạn** (hai lệnh `FROM`).

```
GIAI ĐOẠN 1 "build"  ("xưởng")          GIAI ĐOẠN 2 (căn nhà thật)
 - tải Python                            - tải Python gọn
 - cài thư viện vào /opt/venv   ──────►  - chỉ lấy /opt/venv sang
 - (công cụ cài đặt ở lại đây)           - chép app.py
                                         - chạy bằng tài khoản thường "app"
```

| Quyết định | Lý do dễ hiểu |
|---|---|
| Hai giai đoạn (multi-stage) | Image cuối không mang theo công cụ cài đặt thừa: nhỏ hơn và ít chỗ cho kẻ xấu lợi dụng |
| Ghim `python:3.12-slim` | Hôm nay hay năm sau build ra vẫn giống nhau |
| Chép `requirements.txt` trước `app.py` | Sửa code không phải cài lại thư viện (tận dụng cache) |
| `USER app` | Không chạy bằng quyền tối cao |
| `HEALTHCHECK` gọi `/api/health` | Docker biết API khỏe thật hay chỉ "đang chạy" (nó còn thử nói chuyện với DB) |
| `CMD ["gunicorn", ...]` dạng danh sách | Nhận lệnh dừng đúng cách, tắt nhanh và gọn |
| `--worker-tmp-dir /dev/shm` | Cho phép chạy khi hệ thống file ở chế độ chỉ đọc (xem bước 4) |

### 2.2 Dockerfile của giao diện: `ung-dung/frontend/Dockerfile`
Rất ngắn vì giao diện chỉ là file tĩnh: lấy nginx, chép file cấu hình, chép thư mục `public/`. Cũng có `HEALTHCHECK` gọi `/healthz`.

Trong `nginx.conf` có hai ý quan trọng:
- `location /api/ { ... proxy_pass ... }` → mọi yêu cầu `/api/...` được chuyển vào dịch vụ `api`.
- `resolver 127.0.0.11 valid=10s;` → nginx tra lại địa chỉ của `api` mỗi 10 giây. Nếu thiếu dòng này, khi container `api` được tạo lại và đổi địa chỉ, nginx vẫn gọi vào địa chỉ cũ và trả lỗi 502 cho tới khi khởi động lại nginx. Đây là bẫy rất hay gặp.

### 2.3 File `.dockerignore`
Mỗi phần có một file `.dockerignore` loại những thứ không nên đưa vào image (`.git`, `.env`, `__pycache__`...). Quan trọng nhất là `.env`: không để mật khẩu lọt vào image.

### 2.4 Thử từng image một (chưa cần Compose)
```sh
# Giao diện
docker build -t viec-can-lam-web:test ung-dung/frontend
docker run --rm -d --name thu-web -p 8081:80 viec-can-lam-web:test
curl -i http://localhost:8081/healthz           # PowerShell: curl.exe -i http://localhost:8081/healthz
docker rm -f thu-web

# API
docker build -t viec-can-lam-api:test ung-dung/api
docker images viec-can-lam-api:test              # xem dung lượng
docker run --rm viec-can-lam-api:test whoami     # phải in ra "app", không phải "root"
```
(API chưa chạy thử riêng được vì cần cơ sở dữ liệu; sẽ chạy ở bước 3.)

## Kiểm tra (bạn đã xong bước 2 khi…)
- [ ] Hai image đóng gói thành công.
- [ ] `whoami` trong image API in ra `app`.
- [ ] `/healthz` của giao diện trả về `ok`.
- [ ] Bạn giải thích được vì sao có hai giai đoạn trong Dockerfile của API.

## Bài tập
1. Đóng gói API lần hai sau khi thêm một dòng ghi chú vào `app.py`. Giai đoạn nào được dùng lại từ cache, giai đoạn nào làm lại?
2. So dung lượng image API với một phiên bản "một giai đoạn" bạn tự viết (cài thư viện thẳng vào image cuối). Chênh bao nhiêu?
3. Xóa dòng `USER app`, đóng gói lại, chạy `whoami`. Thấy gì? Vì sao đó là điều không nên?

Tiếp theo: [Bước 3: Môi trường phát triển](03-moi-truong-phat-trien.md)
