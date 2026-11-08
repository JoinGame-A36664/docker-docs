# Bước 5: Bí mật và cấu hình

## Mục tiêu
Biết **cái gì để ở đâu**. Sai lầm phổ biến nhất của người mới là gõ mật khẩu thẳng vào file cấu hình rồi đẩy lên git. Một khi lên git, coi như ai cũng thấy được.

## Hai loại thông tin, hai chỗ để

| Loại | Ví dụ | Để ở đâu | Có đưa lên git không? |
|---|---|---|---|
| **Cấu hình** (không nhạy cảm) | Cổng, số phiên bản, tên cơ sở dữ liệu | File `.env` và `compose.yaml` | `.env.example` (mẫu) có; `.env` thật thì **không** |
| **Bí mật** (nhạy cảm) | Mật khẩu cơ sở dữ liệu, khóa API | File trong thư mục `bi-mat/`, đưa vào container bằng `secrets` | **Không bao giờ** |

Hình dung: cấu hình là tờ giấy dán ngoài cửa ("phòng này giờ mở cửa 8 giờ"); bí mật là chìa khóa giao riêng cho từng người.

## Vì sao không truyền mật khẩu bằng biến môi trường cho nhanh?
Biến môi trường (`environment: DB_PASSWORD: abc123`) tiện nhưng:
- Hiện ra khi gõ `docker inspect`, ai có quyền chạy Docker đều đọc được.
- Hay bị ghi nhầm vào nhật ký khi chương trình báo lỗi.
- Dễ bị chép nhầm vào file cấu hình rồi đưa lên git.

Dùng `secrets`: mật khẩu là **file** nằm ở `/run/secrets/<tên>` bên trong container. Cấu hình chỉ ghi **đường dẫn** tới file, không ghi mật khẩu.

## Làm gì

### 5.1 Tạo mật khẩu
```sh
sh bi-mat/tao-bi-mat.sh              # Linux / macOS / Git Bash
./bi-mat/tao-bi-mat.ps1              # Windows PowerShell
```
Script tạo file `bi-mat/db_password.txt` chứa 24 ký tự ngẫu nhiên. Nó **không ghi đè** nếu file đã có (vì ghi đè sẽ làm mất mật khẩu của cơ sở dữ liệu đang chạy).

Tự kiểm tra file **không** bị git theo dõi:
```sh
git status --short bi-mat
git check-ignore -v bi-mat/db_password.txt     # phải in ra một dòng chỉ tới .gitignore
```

### 5.2 Xem mật khẩu đi từ đâu tới đâu
```
bi-mat/db_password.txt   (file trên máy)
        │   khai báo ở khối "secrets:" cuối compose.yaml
        ▼
/run/secrets/db_password (file bên trong container db và api)
        │                          │
        ▼                          ▼
 POSTGRES_PASSWORD_FILE      DB_PASSWORD_FILE
 (db đặt mật khẩu bằng nó)   (api đọc nó để đăng nhập db)
```
Trong `app.py`, hàm `doc_mat_khau()` đọc file này. Mật khẩu **không** xuất hiện trong `compose.yaml`, `docker inspect`, hay nhật ký.

### 5.3 Vì sao file mật khẩu để quyền 644?
Container `api` chạy bằng tài khoản `app`, khác tài khoản của bạn trên máy chủ. Nếu file chỉ cho chủ sở hữu đọc (600), `api` sẽ báo `Permission denied`. Cách xử lý của dự án: file để 644, nhưng **khóa cả thư mục `bi-mat/`** bằng quyền 700 để người khác trên máy chủ không vào được. (Trên Windows/Docker Desktop, phần quyền này không áp dụng như vậy; bạn chỉ cần không đưa file lên git.)

### 5.4 Bẫy lớn: đổi file mật khẩu KHÔNG đổi mật khẩu trong cơ sở dữ liệu
PostgreSQL chỉ đọc mật khẩu từ `POSTGRES_PASSWORD_FILE` **một lần duy nhất**, lúc tạo cơ sở dữ liệu lần đầu. Sau đó, sửa file chỉ làm `api` dùng mật khẩu mới trong khi cơ sở dữ liệu vẫn giữ mật khẩu cũ → `api` không đăng nhập được.

Đổi mật khẩu đúng cách:
```sh
# 1) Đổi mật khẩu bên trong cơ sở dữ liệu (thay MAT_KHAU_MOI bằng mật khẩu mới, chỉ dùng chữ và số)
docker compose exec db psql -U app -d appdb -c "ALTER USER app PASSWORD 'MAT_KHAU_MOI';"
# 2) Ghi đúng mật khẩu đó vào file (không có dấu xuống dòng ở cuối)
printf '%s' 'MAT_KHAU_MOI' > bi-mat/db_password.txt
# 3) Cho api đọc lại file
docker compose restart api
```
Hoặc cách "làm lại từ đầu" khi chưa có dữ liệu quan trọng: `docker compose down -v`, xóa `bi-mat/db_password.txt`, tạo lại bằng script, `up -d`.

### 5.5 Thử phá để hiểu
1. Tạo lại trạng thái mới: `docker compose down -v`.
2. Sửa nội dung `bi-mat/db_password.txt` thành một chuỗi khác.
3. `docker compose up -d`. Cơ sở dữ liệu mới tạo nên dùng mật khẩu mới: chạy bình thường.
4. Giờ **sửa tiếp** file lần nữa (không `down -v`) rồi `docker compose restart api`. Xem `docker compose logs api`: thấy lỗi đăng nhập. Đó là bẫy ở 5.4.

## Những điều nên và không nên
| Nên | Không nên |
|---|---|
| Dùng `secrets` cho mật khẩu | Gõ mật khẩu vào `compose.yaml` hay `Dockerfile` |
| Giữ `.env.example` (mẫu, không bí mật) trong git | Đưa `.env` hay `db_password.txt` lên git |
| Mỗi môi trường (dev, chạy thật) một mật khẩu riêng | Dùng chung một mật khẩu cho mọi nơi |
| Đổi mật khẩu khi có người rời nhóm | `COPY .env` vào image (đã chặn bằng `.dockerignore`) |
| Nếu lỡ đưa mật khẩu lên git: **đổi mật khẩu ngay** | Chỉ xóa file khỏi git rồi coi như xong (lịch sử vẫn còn) |

## Kiểm tra (bạn đã xong bước 5 khi…)
- [ ] `git check-ignore` xác nhận `db_password.txt` bị bỏ qua.
- [ ] Chạy `docker inspect viec-can-lam-api-1` và tìm trong kết quả: **không** thấy mật khẩu, chỉ thấy đường dẫn `/run/secrets/db_password`.
- [ ] Bạn giải thích được bẫy ở mục 5.4.

## Bài tập
Tưởng tượng ứng dụng cần thêm một khóa để gọi dịch vụ gửi email. Hãy mô tả (viết ra giấy, 5 dòng): khóa đó để ở file nào, khai báo `secrets` ra sao, và `app.py` đọc nó thế nào. Gợi ý: làm giống mật khẩu cơ sở dữ liệu.

Tiếp theo: [Bước 6: Sao lưu và khôi phục](06-sao-luu-va-khoi-phuc.md)
