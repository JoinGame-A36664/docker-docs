# Bước 4: Môi trường chạy thật

## Mục tiêu
Cùng một ứng dụng, nhưng cấu hình cho **chạy lâu dài trên máy chủ**: tự bật lại khi sập, không ngốn hết máy, giấu kín những phần không cần lộ, khóa chặt quyền hạn.

File chính là `compose.yaml`. Mọi dòng đều có ghi chú; bài này giúp bạn nhìn tổng thể và hiểu **vì sao** từng quyết định.

## Làm gì

### 4.1 Chạy bản "thật" trên máy bạn
```sh
cp .env.example .env
sh bi-mat/tao-bi-mat.sh
docker compose config -q            # kiểm tra file; không in gì tức là ổn
docker compose up -d --build
docker compose ps                   # đợi tới khi db, api, web đều "healthy"
```
Mở `http://localhost:8080`. Lưu ý: lần này **không có** cổng 5432 mở ra, và không sửa code thấy ngay (vì đây là bản đóng gói chạy thật).

### 4.2 Quan sát chuỗi khởi động
Hệ thống bật theo thứ tự nhờ `healthcheck` + `depends_on`:
```
db (PostgreSQL)  ──khỏe──►  api  ──khỏe──►  web
 pg_isready              /api/health        /healthz
```
Kiểm chứng: chạy `docker compose down` rồi `docker compose up -d` và nhìn `docker compose ps` nhiều lần trong 30 giây đầu: bạn sẽ thấy `db` lên trước, rồi `api`, rồi `web`.

### 4.3 Kiểm chứng "giấu kín"
```sh
# web không với tới db (khác khu mạng) - lệnh báo lỗi là ĐÚNG:
docker compose exec web nslookup db

# api thì thấy db (cùng khu trong):
docker compose exec api python -c "import socket; print(socket.gethostbyname('db'))"

# api chạy bằng tài khoản thường, hệ thống file chỉ đọc:
docker compose exec api whoami
docker compose exec api sh -c "touch /app/thu.txt"     # phải báo lỗi "Read-only file system"
```

## Đọc hiểu `compose.yaml`: các nhóm quyết định

| Nhóm | Dòng trong file | Vì sao |
|---|---|---|
| **Giấu kín** | Chỉ `web` có `ports:` | Kẻ ngoài chỉ thấy một cửa. Muốn tấn công `api` hay `db` phải đi qua `web` |
| **Chia khu mạng** | `networks: khu-ngoai`, `khu-trong` | `web` không nằm trong khu trong nên không với tới `db` |
| **Thứ tự khởi động** | `depends_on: ... condition: service_healthy` | Tránh `api` chạy khi `db` chưa sẵn sàng (gây lỗi lúc khởi động) |
| **Tự phục hồi** | `restart: unless-stopped` | Sập bất ngờ hoặc máy chủ khởi động lại thì tự bật lại. Chỉ không bật lại khi **bạn** chủ động tắt |
| **Giới hạn tài nguyên** | `deploy.resources.limits` | Một phần bị lỗi (ví dụ rò rỉ bộ nhớ) không kéo cả máy chủ chết theo |
| **Giới hạn nhật ký** | `x-nhat-ky` + `<<: *nhat-ky` | Nhật ký không đầy ổ cứng: mỗi container tối đa khoảng 30 MB |
| **Khóa chặt `api`** | `read_only`, `tmpfs`, `cap_drop: ALL`, `no-new-privileges` | Nếu kẻ xấu chiếm được `api` thì nó không ghi được file, không có quyền đặc biệt, không tự nâng quyền |
| **Dữ liệu bền** | `volumes: du-lieu-db` | Xóa container không mất dữ liệu |
| **Bí mật** | `secrets: db_password` | Mật khẩu là file, không nằm trong cấu hình (xem bước 5) |
| **Việc chạy một lần** | `sao-luu` với `profiles` | Không chạy cùng hệ thống, chỉ chạy khi bạn gọi (xem bước 6) |
| **Tên image có phiên bản** | `image: ${IMAGE_PREFIX:-}viec-can-lam-api:${APP_VERSION:-1.0.0}` | Biết đang chạy bản nào, và quay lại bản cũ được (xem bước 9) |

### Đọc kỹ mẫu "viết một lần, dùng nhiều chỗ"
```yaml
x-nhat-ky: &nhat-ky          # "&nhat-ky" dán nhãn cho đoạn cấu hình này
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  web:
    <<: *nhat-ky              # "<<: *nhat-ky" = chép đoạn có nhãn nhat-ky vào đây
```
Giống soạn một mẫu giấy rồi dán vào nhiều chỗ. Sửa mẫu một lần là mọi nơi dùng nó cùng đổi.

## Những bẫy hay gặp
| Triệu chứng | Nguyên nhân | Cách xử lý |
|---|---|---|
| `api` luôn `unhealthy` | Không đọc được mật khẩu hoặc `db` chưa lên | `docker compose logs api db` |
| `Permission denied` khi đọc `/run/secrets/db_password` | File mật khẩu có quyền quá chặt (600) | Chạy lại `tao-bi-mat.sh` (đặt quyền 644), xem bước 5 |
| `web` lỗi 502 | `api` chưa khỏe hoặc đang khởi động lại | Đợi vài giây; xem `docker compose ps` |
| `Read-only file system` khi `api` ghi file | Đúng như thiết kế | Nếu thật sự cần ghi thì thêm `tmpfs` hoặc volume cho **đúng thư mục đó** |
| Đổi `init.sql` mà bảng không đổi | `init.sql` chỉ chạy lần đầu | Xem bước 9 mục "đổi cấu trúc bảng" |

## Nâng cao (đọc cho biết, chưa làm trong dự án này)
- `networks: khu-trong: internal: true` làm khu trong **mất đường ra Internet** (cơ sở dữ liệu không cần ra ngoài). Nhưng lúc đó cổng `5432` ở chế độ phát triển không còn hoạt động, nên cần cân nhắc.
- Chỉ cho phép `web` nhận kết nối từ một địa chỉ cụ thể bằng tường lửa của máy chủ (bước 8).

## Kiểm tra (bạn đã xong bước 4 khi…)
- [ ] Cả 3 dịch vụ `healthy`, mở được trang.
- [ ] Bạn đã chạy 3 lệnh ở mục 4.3 và thấy kết quả đúng như mô tả.
- [ ] Bạn giải thích được vì sao `db` và `api` không có `ports`.
- [ ] Bạn chỉ ra được 3 dòng làm cho `api` "khó bị lợi dụng" nếu bị tấn công.

## Bài tập
1. Giảm giới hạn bộ nhớ của `web` xuống `8M`, chạy lại và quan sát `docker stats` / `docker compose ps`. Chuyện gì xảy ra? Trả lại giá trị cũ.
2. Thử hai cách tắt `api` và quan sát `docker compose ps` sau mỗi lần: `docker kill viec-can-lam-api-1` (giống như bị sập), rồi `docker compose stop api` (bạn chủ động tắt). Ghi lại kết quả, rồi đối chiếu với ý nghĩa của `unless-stopped` ("tự bật lại, **trừ khi** chính bạn đã dừng nó").

Tiếp theo: [Bước 5: Bí mật và cấu hình](05-bi-mat-va-cau-hinh.md)
