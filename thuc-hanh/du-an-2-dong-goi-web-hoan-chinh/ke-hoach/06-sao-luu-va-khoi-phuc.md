# Bước 6: Sao lưu và khôi phục

## Mục tiêu
Lỡ gõ nhầm `docker compose down -v`, lỡ ổ cứng hỏng, lỡ ai xóa nhầm dữ liệu: bạn vẫn lấy lại được. Với một web thật, **dữ liệu là thứ quý nhất**; code mất thì viết lại được, dữ liệu mất thì hết.

> **Một câu để nhớ:** sao lưu mà chưa từng thử khôi phục thì **chưa phải là sao lưu**.

## Ý tưởng
- Dùng công cụ `pg_dump` của PostgreSQL để "chụp" toàn bộ cơ sở dữ liệu thành **một file chữ** (các câu lệnh SQL để dựng lại nó), nén bằng gzip.
- Việc này làm bởi một dịch vụ `sao-luu` trong `compose.yaml`, chạy **một lần rồi dừng**. Nhờ khai báo `profiles`, nó không chạy cùng hệ thống bình thường.
- File lưu ở thư mục `sao-luu/` trên máy bạn, **nằm ngoài Docker**. Như vậy `down -v` cũng không làm mất.

## Làm gì

### 6.1 Chuẩn bị dữ liệu để thử
Mở `http://localhost:8080`, thêm vài việc có tên dễ nhớ, ví dụ "SAO LUU THU 1", "SAO LUU THU 2".

### 6.2 Sao lưu
```sh
docker compose --profile sao-luu run --rm sao-luu
ls -l sao-luu/                    # PowerShell: Get-ChildItem sao-luu
```
**Bạn sẽ thấy:** dòng `Da sao luu xong: /sao-luu/appdb_20..._...sql.gz` và một file `.sql.gz` mới trong thư mục `sao-luu/`.

Xem thử bên trong (không cần giải nén ra file):
```sh
gunzip -c sao-luu/appdb_*.sql.gz | head -40       # cần Git Bash hoặc WSL trên Windows
```
Bạn sẽ thấy các câu lệnh `CREATE TABLE tasks ...` và dữ liệu của bạn. Đó chính là "bản sao" dưới dạng chữ.

### 6.3 Làm mất dữ liệu (cố ý)
```sh
docker compose down -v            # -v xóa luôn ổ lưu dữ liệu
docker compose up -d
```
Mở trang: chỉ còn 3 việc mẫu từ `init.sql`, những việc bạn thêm đã biến mất.

### 6.4 Khôi phục
```sh
sh sao-luu/khoi-phuc.sh sao-luu/TEN_FILE_SAO_LUU.sql.gz
```
Gõ `dong y` khi được hỏi. Tải lại trang: các việc "SAO LUU THU 1", "SAO LUU THU 2" đã trở lại.

Script làm hai việc: xóa bảng `tasks` hiện tại, rồi nạp lại từ file bằng `psql`. Có thể làm tay:
```sh
gunzip -c sao-luu/TEN_FILE.sql.gz | docker compose exec -T db psql -U app -d appdb -v ON_ERROR_STOP=1
```
(`-T` cần thiết khi đưa dữ liệu vào bằng dấu `|`.)

### 6.5 Lên lịch sao lưu tự động
Sao lưu thủ công thì sẽ quên. Đặt lịch chạy mỗi đêm.

**Linux** (gõ `crontab -e`, thêm một dòng; chạy 2 giờ sáng mỗi ngày; sửa đường dẫn cho đúng):
```
0 2 * * * cd /duong/dan/du-an && docker compose --profile sao-luu run --rm sao-luu >> sao-luu/sao-luu.log 2>&1
```
**Windows:** dùng *Task Scheduler*, chạy `docker compose --profile sao-luu run --rm sao-luu` với thư mục làm việc là thư mục dự án.

### 6.6 Dọn các bản sao lưu cũ
Giữ 14 ngày gần nhất (Linux), thêm vào cron:
```
30 2 * * * find /duong/dan/du-an/sao-luu -name 'appdb_*.sql.gz' -mtime +14 -delete
```

## Đọc hiểu dịch vụ `sao-luu` trong `compose.yaml`
| Dòng | Nghĩa dễ hiểu |
|---|---|
| `profiles: [sao-luu]` | Dịch vụ này chỉ bật khi bạn chỉ định `--profile sao-luu` |
| `depends_on: db: condition: service_healthy` | Chờ cơ sở dữ liệu khỏe rồi mới sao lưu |
| `volumes: ./sao-luu:/sao-luu` | Gắn thư mục `sao-luu` trên máy vào container, để file sao lưu nằm lại máy bạn |
| `entrypoint: ["/bin/sh","-c"]` + `command: [...]` | Chạy một đoạn lệnh shell do mình viết |
| `$$(date ...)` | Viết hai dấu `$` để Compose **không tự thay** mà để nguyên cho shell xử lý |
| `set -e` | Có lệnh nào lỗi là dừng ngay, không chạy tiếp |
| `pg_dump -h db -U app appdb > file` | "Chụp" cơ sở dữ liệu `appdb` thành file |
| `restart: "no"` | Chạy xong là thôi, không tự bật lại |

## Quy tắc 3-2-1 (nhớ thế này là đủ)
- **3** bản dữ liệu: bản đang chạy + 2 bản sao lưu.
- **2** nơi lưu khác nhau (ví dụ ổ cứng máy chủ **và** một dịch vụ lưu trữ đám mây).
- **1** bản nằm **xa** máy chủ (khác máy, khác địa điểm).

Thư mục `sao-luu/` trên cùng máy chủ chỉ là bản thứ nhất. Mất cả máy chủ là mất luôn. Việc chép các file `.sql.gz` sang nơi khác (`rclone`, `scp`, dịch vụ lưu trữ của nhà cung cấp) là việc bạn cần làm tiếp.

## Kiểm tra (bạn đã xong bước 6 khi…)
- [ ] Có file `.sql.gz` trong `sao-luu/`.
- [ ] Bạn đã làm mất dữ liệu cố ý và **khôi phục thành công**.
- [ ] Bạn đã viết ra (giấy cũng được) lịch sao lưu và nơi chép bản sao đi xa.

## Bài tập
1. Sao lưu rồi mở file `.sql.gz` ra đọc. Tìm dòng `COPY public.tasks` hoặc các `INSERT`, nhận ra dữ liệu của bạn.
2. Lưu ý: sao lưu bằng `pg_dump` **không** gồm mật khẩu của tài khoản. Vì sao việc khôi phục sang máy mới vẫn cần chuẩn bị file `bi-mat/db_password.txt` trước?

Tiếp theo: [Bước 7: Tự động hóa kiểm tra và đóng gói (CI)](07-tu-dong-hoa-ci.md)
