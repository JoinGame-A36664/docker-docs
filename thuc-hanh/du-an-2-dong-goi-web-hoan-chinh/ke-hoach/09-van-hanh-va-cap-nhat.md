# Bước 9: Vận hành và cập nhật

## Mục tiêu
Hệ thống đã chạy. Giờ là phần **sống chung lâu dài**: cập nhật phiên bản mới mà không rối, quay lại bản cũ khi có sự cố, đổi cấu trúc cơ sở dữ liệu một cách an toàn, và biết nhìn vào đâu khi có chuyện.

## 9.1 Cập nhật phiên bản mới (quy trình 5 bước)

```
 1. Sao lưu ──► 2. Tăng số phiên bản ──► 3. Lấy/Đóng gói bản mới ──► 4. Thay thế ──► 5. Kiểm tra
```
```sh
# 1) Sao lưu trước, luôn luôn
docker compose --profile sao-luu run --rm sao-luu

# 2) Tăng số phiên bản trong .env, ví dụ APP_VERSION=1.0.0 -> 1.1.0
nano .env

# 3) Lấy image mới (cách B ở bước 8) HOẶC đóng gói tại chỗ (cách A)
docker compose pull            # cách B
docker compose build           # cách A

# 4) Thay thế. Compose chỉ tạo lại những dịch vụ có thay đổi
docker compose up -d

# 5) Kiểm tra
docker compose ps
curl -fsS http://localhost/api/health
```
Nhờ có `healthcheck` và `depends_on`, dịch vụ được thay theo thứ tự đúng. Nhờ dòng `resolver` trong `nginx.conf`, khi `api` được tạo lại, `web` tự tìm ra địa chỉ mới, bạn không phải khởi động lại `web`.

Lưu ý: cách này có một khoảng gián đoạn ngắn (vài giây) lúc thay `api`. Hệ thống lớn hơn dùng kỹ thuật cập nhật không gián đoạn (nhiều bản sao + cân bằng tải), đó là chủ đề tiếp theo khi bạn học Kubernetes hoặc Docker Swarm.

## 9.2 Quay lại bản cũ (rollback)
Vì mỗi image có **số phiên bản trong tên**, quay lại chỉ là đổi số:
```sh
# trong .env đổi APP_VERSION=1.1.0 -> 1.0.0
docker compose up -d
```
(Cách B: image bản cũ vẫn còn trên kho. Cách A: cần đóng gói lại từ code ở nhãn git tương ứng: `git checkout v1.0.0` rồi `docker compose up -d --build`.)

Điều **không** quay lại được bằng cách này là thay đổi trong cơ sở dữ liệu. Vì vậy mới có bước "sao lưu trước" ở 9.1.

## 9.3 Đổi cấu trúc bảng một cách an toàn
`init.sql` chỉ chạy **lần đầu** khi ổ dữ liệu trống. Muốn đổi cấu trúc khi đã có dữ liệu thật, cần một file "nâng cấp" riêng và chạy tay đúng một lần.

Ví dụ thêm cột ghi chú. Tạo file `ung-dung/db/nang-cap/0002-them-cot-ghi-chu.sql`:
```sql
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS ghi_chu TEXT;
```
Rồi:
```sh
docker compose --profile sao-luu run --rm sao-luu                    # sao lưu trước!
docker compose exec -T db psql -U app -d appdb -v ON_ERROR_STOP=1 < ung-dung/db/nang-cap/0002-them-cot-ghi-chu.sql
```
Quy tắc vàng:
- Đặt tên file theo số thứ tự (0002, 0003...) để biết đã chạy tới đâu.
- Viết sao cho **chạy lại không hỏng** (`IF NOT EXISTS`).
- Thay đổi cấu trúc nên **tương thích ngược** với bản `api` cũ trong lúc chuyển đổi (thêm cột trước, xóa cột để sau).
- Ghi lại file nào đã chạy trên máy chủ nào. (Công cụ chuyên dụng cho việc này: Alembic, Flyway, Liquibase.)

## 9.4 Nhìn vào đâu khi có chuyện?

| Bạn thấy | Xem ở đâu | Lệnh |
|---|---|---|
| Trang không vào được | Dịch vụ nào đang chết | `docker compose ps` |
| Trang báo lỗi 502 / 503 | Nhật ký `web` và `api` | `docker compose logs --tail 50 web api` |
| `api` báo không kết nối được DB | Nhật ký `db`; mật khẩu | `docker compose logs db`; xem bước 5 mục 5.4 |
| Chậm hoặc đứng | CPU / bộ nhớ có chạm giới hạn không | `docker stats` |
| Máy chủ đầy ổ cứng | Dung lượng Docker chiếm | `docker system df` |
| Muốn xem chi tiết một container | Cấu hình, trạng thái healthcheck | `docker inspect <tên>` |
| Muốn thử lệnh bên trong | Vào container | `docker compose exec api sh` |

Thói quen tốt: **đọc nhật ký trước, đoán sau.**

## 9.5 Việc định kỳ
| Tần suất | Việc |
|---|---|
| Hàng ngày (tự động) | Sao lưu cơ sở dữ liệu; kiểm tra bản sao lưu có được tạo |
| Hàng tuần | Xem `docker compose ps`, `docker stats`, dung lượng ổ cứng |
| Hàng tháng | Cập nhật hệ điều hành máy chủ (`apt upgrade`); cập nhật image gốc (đóng gói lại để nhận bản vá); **thử khôi phục** một bản sao lưu |
| Mỗi quý | Xem lại: ai còn quyền vào máy chủ? Có mật khẩu cần đổi? Phiên bản Postgres/Python còn được hỗ trợ không? |

Dọn dẹp image cũ không còn dùng:
```sh
docker image prune -f              # xóa image mồ côi
docker system df                   # xem kết quả
```
(Cẩn thận với `docker system prune --volumes`: có thể xóa cả ổ dữ liệu không có container nào đang dùng.)

## 9.6 Nâng cấp phiên bản lớn của PostgreSQL (ví dụ 16 → 17)
**Không** chỉ đổi số trong `image: postgres:16-alpine` rồi chạy: dữ liệu cũ không tương thích với phiên bản lớn mới. Cách an toàn:
1. Sao lưu bằng `pg_dump` (bước 6).
2. Dựng một cơ sở dữ liệu **mới** bản 17 với ổ dữ liệu mới.
3. Khôi phục dữ liệu vào đó.
4. Kiểm tra kỹ, chuyển `api` sang dùng cơ sở dữ liệu mới.
Luôn thử toàn bộ trên máy phát triển trước.

## Tổng kết hành trình
Bạn đã đi qua đủ vòng đời đóng gói một web: **phân tích → Dockerfile → phát triển → chạy thật → bí mật → sao lưu → tự động hóa → triển khai → vận hành**. Mỗi bước có một file kiểm tra riêng. Đem [Danh sách kiểm tra](danh-sach-kiem-tra.md) áp dụng cho web của chính bạn.

## Kiểm tra (bạn đã xong bước 9 khi…)
- [ ] Bạn đã thực hành một vòng cập nhật (tăng số phiên bản, thay thế) và một vòng quay lại bản cũ.
- [ ] Bạn đã thử thêm một cột bằng file nâng cấp sau khi sao lưu.
- [ ] Bạn biết xem nhật ký, trạng thái, và dung lượng khi có chuyện.

## Bài tập cuối
Áp dụng cả quy trình 9 bước cho **một web của chính bạn** (hoặc một ví dụ mã nguồn mở nhỏ). Điền [Danh sách kiểm tra](danh-sach-kiem-tra.md) từ đầu đến cuối. Chỗ nào chưa tick được chính là việc cần làm tiếp.
