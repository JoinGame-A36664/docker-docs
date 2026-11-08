# Dự án 2: Kế hoạch đóng gói một web hoàn chỉnh

Ở dự án 1, bạn học từng khái niệm với một ứng dụng nhỏ. Dự án này **làm như thật**: bạn nhận một web đầy đủ (có giao diện, có phần xử lý, có cơ sở dữ liệu) và lập **kế hoạch đóng gói** nó để chạy ổn định, an toàn, dễ cập nhật.

"Đóng gói" ở đây không chỉ là viết Dockerfile. Nó là cả một quy trình: **phân tích → đóng gói từng phần → chạy thử → làm cho an toàn → sao lưu → tự động hóa → đem lên máy chủ → vận hành**.

## Ứng dụng: "Việc cần làm"

Một trang web ghi chú công việc: thêm việc, bấm vào việc để đánh dấu xong, xóa việc.

```
                    ┌──────────────────────── máy của bạn / máy chủ ────────────────────────┐
 Trình duyệt ─────► │  web (nginx)  ─────►  api (Flask)  ─────►  db (PostgreSQL)             │
   cổng 8080        │  giao diện + lễ tân     xử lý công việc      lưu dữ liệu lâu dài        │
                    │   [khu ngoài]       [khu ngoài + khu trong]      [khu trong]            │
                    └────────────────────────────────────────────────────────────────────────┘
```

| Phần | Vai trò | Công nghệ | Mở cổng ra ngoài? |
|---|---|---|---|
| `web` | Phát giao diện, chuyển yêu cầu `/api/...` vào `api` | nginx + HTML/CSS/JS | **Có** (cổng duy nhất) |
| `api` | Xử lý: xem, thêm, đổi trạng thái, xóa việc | Python (Flask + gunicorn) | Không |
| `db` | Lưu dữ liệu | PostgreSQL 16 | Không (trừ khi bật chế độ phát triển) |
| `sao-luu` | Công việc chạy một lần để sao lưu `db` | PostgreSQL (công cụ `pg_dump`) | Không |

## Chạy nhanh để xem trước (khoảng 5 phút)

Mở dòng lệnh tại thư mục này (`thuc-hanh/du-an-2-dong-goi-web-hoan-chinh`):

```sh
cp .env.example .env                  # PowerShell: Copy-Item .env.example .env
sh bi-mat/tao-bi-mat.sh               # PowerShell: ./bi-mat/tao-bi-mat.ps1   (tạo mật khẩu cơ sở dữ liệu)
docker compose config -q              # kiểm tra file; không in gì ra tức là ổn
docker compose up -d --build
docker compose ps                     # đợi tới khi cả 3 dịch vụ có chữ "healthy"
```
Mở `http://localhost:8080`. Bạn sẽ thấy 3 việc mẫu. Thêm một việc, bấm vào nó để gạch ngang, rồi xóa nó.

Tắt: `docker compose down` (giữ dữ liệu) hoặc `docker compose down -v` (xóa luôn dữ liệu).

Muốn sửa code và thấy ngay, xem [bước 3](ke-hoach/03-moi-truong-phat-trien.md).

## Kế hoạch 9 bước

Đọc và làm theo thứ tự. Mỗi bước là một file trong thư mục [`ke-hoach/`](ke-hoach/). Mỗi file đều có: **mục tiêu**, **làm gì**, **kiểm tra**.

| Bước | Tên | Câu hỏi mà bước này trả lời |
|---|---|---|
| 1 | [Phân tích ứng dụng](ke-hoach/01-phan-tich-ung-dung.md) | Ứng dụng gồm những phần nào? Phần nào cần lưu dữ liệu, mật khẩu, cổng? |
| 2 | [Viết Dockerfile cho từng phần](ke-hoach/02-viet-dockerfile.md) | Làm sao mỗi phần thành một image nhỏ, sạch, an toàn? |
| 3 | [Môi trường phát triển](ke-hoach/03-moi-truong-phat-trien.md) | Làm sao vừa sửa code vừa thấy kết quả ngay? |
| 4 | [Môi trường chạy thật](ke-hoach/04-moi-truong-chay-that.md) | Làm sao cho hệ thống bền, giấu kín, có giới hạn? |
| 5 | [Bí mật và cấu hình](ke-hoach/05-bi-mat-va-cau-hinh.md) | Mật khẩu để ở đâu cho an toàn? |
| 6 | [Sao lưu và khôi phục](ke-hoach/06-sao-luu-va-khoi-phuc.md) | Lỡ mất dữ liệu thì sao? |
| 7 | [Tự động hóa kiểm tra và đóng gói (CI)](ke-hoach/07-tu-dong-hoa-ci.md) | Làm sao máy tự kiểm tra và đóng gói mỗi lần có code mới? |
| 8 | [Đưa lên máy chủ](ke-hoach/08-trien-khai-len-may-chu.md) | Cần chuẩn bị gì để chạy trên máy chủ thật? |
| 9 | [Vận hành và cập nhật](ke-hoach/09-van-hanh-va-cap-nhat.md) | Cập nhật bản mới, quay lại bản cũ, sửa lỗi như thế nào? |

Cuối cùng có [Danh sách kiểm tra](ke-hoach/danh-sach-kiem-tra.md) để đánh dấu từng việc. Dùng nó cho **bất kỳ web nào** của bạn sau này, không chỉ ứng dụng này.

## Cấu trúc thư mục

```
du-an-2-dong-goi-web-hoan-chinh/
├── README.md                    ← bạn đang đọc
├── ke-hoach/                    ← 9 bước kế hoạch + danh sách kiểm tra
├── ung-dung/                    ← mã nguồn của web
│   ├── frontend/                  giao diện + nginx (Dockerfile, nginx.conf, public/)
│   ├── api/                       phần xử lý (Dockerfile, app.py, requirements.txt)
│   └── db/init.sql                tạo bảng lần đầu
├── compose.yaml                 ← cách chạy THẬT (giải thích từng dòng trong file)
├── compose.dev.yaml             ← phần bổ sung khi PHÁT TRIỂN
├── .env.example                 ← cấu hình mẫu (không có mật khẩu)
├── bi-mat/                      ← nơi đặt mật khẩu (file thật không đưa lên git) + script tạo
├── sao-luu/                     ← nơi chứa file sao lưu + script khôi phục
└── ci/github-actions-mau.yml    ← mẫu quy trình tự động
```

## Điều bạn cần biết trước khi làm
- Đã làm xong [Dự án 1](../du-an-1-so-luu-but/README.md), đặc biệt giai đoạn 4 đến 6 (Compose).
- Mỗi file YAML trong dự án đều có ghi chú **từng dòng**. Mở file ra đọc song song với bước kế hoạch.
- Dự án là để **học quy trình**. Phần HTTPS (khóa xanh) và giám sát nâng cao được nói ở bước 8 và 9 như việc cần làm tiếp, chưa có sẵn mã.
- Khi hệ thống đã chạy được ở bước "chạy nhanh", đừng ngại phá thử: `docker compose down -v` rồi dựng lại là xong.
