# Thực hành Docker: học bằng cách làm

Đọc tài liệu rất dễ buồn ngủ. Thư mục này để bạn **gõ lệnh và nhìn thấy kết quả**. Mọi thứ đều chạy được trên máy của bạn, và mỗi bài chỉ dạy **một ý mới**.

## Có hai dự án, làm theo thứ tự

```
thuc-hanh/
├── 00-tu-dien-de-hieu.md           ← các từ khó, giải thích bằng ví dụ đời thường (đọc trước, 5 phút)
│
├── du-an-1-so-luu-but/             ← DỰ ÁN 1: học từng giai đoạn, từ container đầu tiên đến nhiều container chạy cùng nhau
│   ├── giai-doan-1-chay-container/
│   ├── giai-doan-2-dong-goi-ung-dung/
│   ├── giai-doan-3-noi-mang-bang-tay/
│   ├── giai-doan-4-compose/
│   ├── giai-doan-5-them-nginx/
│   ├── giai-doan-6-van-hanh/
│   └── ung-dung/                   ← mã nguồn của ứng dụng (dùng chung cho cả 6 giai đoạn)
│
└── du-an-2-dong-goi-web-hoan-chinh/ ← DỰ ÁN 2: kế hoạch đóng gói MỘT WEB ĐẦY ĐỦ (giao diện + máy chủ + cơ sở dữ liệu)
```

## Dự án 1 và dự án 2 khác nhau thế nào?

| | Dự án 1: Sổ lưu bút | Dự án 2: Web hoàn chỉnh |
|---|---|---|
| Mục đích | **Học** từng khái niệm một | **Làm như thật**: đóng gói một web để đem đi chạy |
| Cách học | Mỗi giai đoạn thêm một ý mới, có bài tập nhỏ | Đi theo kế hoạch 8 bước, như một dự án thật |
| Quy mô | 3 container | 3 container + sao lưu + bí mật + tự động hóa |
| Khi nào làm | Làm trước | Làm sau khi xong dự án 1 |

## Cách học (rất quan trọng)

1. **Làm đúng thứ tự giai đoạn.** Giai đoạn sau dùng thứ bạn vừa học ở giai đoạn trước.
2. **Mỗi giai đoạn có một thư mục riêng** và một file `README.md` bên trong. Mở file đó ra và làm theo từ trên xuống.
3. Trong mỗi giai đoạn bạn sẽ gặp 4 phần giống nhau:
   - **Ở giai đoạn này bạn học gì**: một ý duy nhất.
   - **Làm theo**: các lệnh để gõ.
   - **Bạn sẽ thấy**: kết quả đúng trông như thế nào, để tự biết mình làm đúng chưa.
   - **Tự kiểm tra**: vài câu hỏi ngắn. Trả lời được là bạn đã hiểu.
4. Gặp lỗi? Đừng lo, xem bảng **"Gỡ rối"** ở cuối `du-an-1-so-luu-but/README.md`.
5. Dọn dẹp cuối mỗi giai đoạn (có lệnh sẵn) để giai đoạn sau không bị lẫn.

## Chuẩn bị (làm một lần)

1. Cài Docker: xem [Hướng dẫn cài đặt Docker](../docs/docker-coban/docker-thuchanh-caidat.md). Nếu dùng Windows 10/11 hoặc macOS, cài **Docker Desktop** rồi mở nó lên, đợi đến khi báo "đang chạy".
2. Mở **một cửa sổ dòng lệnh** (Terminal, PowerShell, hoặc Ubuntu trong WSL) và kiểm tra:
   ```sh
   docker --version
   docker compose version
   ```
   Thấy hiện số phiên bản là xong. Nếu báo lỗi "không tìm thấy lệnh" thì Docker chưa cài đúng.
3. Dùng **Windows PowerShell** thì để ý: vài lệnh viết hơi khác bash. Các bài có ghi rõ chỗ khác.

## Muốn đọc thêm lý thuyết?
Khi gặp từ lạ, xem [Từ điển dễ hiểu](00-tu-dien-de-hieu.md). Muốn hiểu sâu hơn thì quay lại phần tài liệu trong thư mục [`docs/`](../docs/); mỗi giai đoạn có ghi bài tương ứng.
