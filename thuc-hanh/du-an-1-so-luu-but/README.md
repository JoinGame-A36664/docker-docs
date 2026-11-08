# Dự án 1: Sổ lưu bút Docker

Bạn sẽ làm một **trang sổ lưu bút**: ai vào cũng gõ được một dòng lời nhắn, trang đếm xem có bao nhiêu lượt xem. Trang hiện luôn **tên "căn phòng" (container) đang phục vụ bạn**, để bạn tận mắt thấy Docker làm việc.

Điểm hay của dự án: ứng dụng chỉ có một, nhưng bạn sẽ **chạy nó theo 6 cách khác nhau, mỗi lần chuyên nghiệp hơn một chút**. Đó cũng chính là con đường mà người ta thực sự đi khi đưa một ứng dụng vào Docker.

## Ứng dụng gồm những gì?

```
 Người dùng
     │
     ▼
 ┌────────┐      ┌────────┐      ┌────────┐
 │ nginx  │ ───► │  web   │ ───► │ redis  │
 │ (lễ tân)│      │(trang web)│    │(sổ ghi) │
 └────────┘      └────────┘      └────────┘
```

- **web**: chương trình viết bằng Python. Nó hiện trang, nhận lời nhắn, đếm lượt xem.
- **redis**: một "cuốn sổ" lưu số đếm và lời nhắn. Web chỉ biết hỏi và ghi vào sổ này.
- **nginx**: "lễ tân" đứng trước. Người ngoài chỉ gặp lễ tân; lễ tân chuyển yêu cầu vào cho web. (Chỉ có từ giai đoạn 5.)

## Lộ trình 6 giai đoạn

Mỗi giai đoạn giải quyết **vấn đề còn lại của giai đoạn trước**. Đó là lý do phải làm theo thứ tự.

| # | Thư mục | Bạn làm gì | Vấn đề còn lại, dẫn sang giai đoạn sau |
|---|---|---|---|
| 1 | `giai-doan-1-chay-container` | Chạy container có sẵn (nginx) và nhìn thấy trang web | Đang dùng đồ người khác làm. Muốn chạy **ứng dụng của mình** |
| 2 | `giai-doan-2-dong-goi-ung-dung` | Viết Dockerfile, đóng gói ứng dụng thành image | Ứng dụng cần "cuốn sổ" redis nhưng chưa có |
| 3 | `giai-doan-3-noi-mang-bang-tay` | Cho web và redis nói chuyện bằng mạng riêng + giữ dữ liệu bằng volume, **gõ lệnh bằng tay** | Phải nhớ cả đống lệnh dài, rất dễ gõ sai |
| 4 | `giai-doan-4-compose` | Viết **một file YAML** thay cho cả đống lệnh | Web đang mở thẳng ra ngoài, chưa an toàn |
| 5 | `giai-doan-5-them-nginx` | Thêm nginx làm "lễ tân", chia mạng, chỉ mở một cửa | Chưa biết cách theo dõi, sửa lỗi, dọn dẹp |
| 6 | `giai-doan-6-van-hanh` | Xem log, giới hạn tài nguyên, sửa code thấy ngay, dọn dẹp | (Xong dự án 1. Sang dự án 2.) |

Mã nguồn ứng dụng nằm ở thư mục [`ung-dung/`](ung-dung). **Bạn không cần biết Python và không phải sửa code.** Chỉ khi muốn thì mở ra đọc.

## Quy ước trong các bài

- Dòng lệnh nằm trong khung có chữ `sh`. Dùng **PowerShell** thì chỗ nào khác sẽ ghi riêng.
- Chỗ nào viết `# ...` trong khung lệnh là **ghi chú**, bạn không cần gõ phần đó.
- Câu "**Bạn sẽ thấy**" nói kết quả đúng. Không giống thì xem bảng gỡ rối bên dưới.

## Gỡ rối thường gặp

| Triệu chứng | Nguyên nhân hay gặp | Cách xử lý |
|---|---|---|
| `port is already allocated` hoặc `address already in use` | Cổng 8080 (hoặc 8000) đang có chương trình khác dùng | Đổi con số **bên trái** dấu `:` thành số khác, ví dụ `-p 9090:80`. Với Compose thì đổi `HTTP_PORT` trong file `.env` |
| `Cannot connect to the Docker daemon` | Docker chưa chạy | Mở Docker Desktop; trên Linux `sudo systemctl start docker` |
| `permission denied ... docker.sock` (Linux) | Tài khoản của bạn chưa được dùng Docker | `sudo usermod -aG docker $USER` rồi đăng xuất, đăng nhập lại |
| `no configuration file provided: not found` | Đang đứng sai thư mục | `cd` vào đúng thư mục giai đoạn (chỗ có file `compose.yaml`) |
| `name "..." is already in use` | Container cùng tên còn sót từ lần trước | `docker rm -f <tên>`, hoặc chạy lệnh dọn dẹp ở cuối giai đoạn trước |
| Sửa code mà trang không đổi | Image cũ vẫn đang dùng | `docker compose up -d --build` (xây lại rồi chạy) |
| Mở trang thấy khung lỗi đỏ "Không kết nối được tới Redis" | Web chạy nhưng chưa có redis đi kèm | Bình thường ở giai đoạn 2. Từ giai đoạn 3 trở đi nghĩa là redis chưa chạy hoặc khác mạng |
| Trang không vào được ngay sau khi `up` | Container chưa kịp "khỏe" | Đợi vài giây, xem `docker compose ps` |

## Ghi chú phạm vi
Đây là dự án để học: không có đăng nhập, không có HTTPS, redis không đặt mật khẩu. **Đừng đưa nguyên bản này lên Internet.** Dự án 2 sẽ làm những việc cần thiết hơn để chạy thật.

Xong giai đoạn 6, sang [Dự án 2: đóng gói một web hoàn chỉnh](../du-an-2-dong-goi-web-hoan-chinh/README.md).
