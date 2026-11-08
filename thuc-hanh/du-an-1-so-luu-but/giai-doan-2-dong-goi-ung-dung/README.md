# Giai đoạn 2: Đóng gói ứng dụng của mình (Dockerfile)

## Ở giai đoạn này bạn học gì?
Chỉ **một ý**: viết một **Dockerfile** (công thức), rồi dùng nó để làm ra một **image** (khuôn) chứa ứng dụng sổ lưu bút. Sau đó chạy một container từ image đó.

Đọc thêm nếu thích: [Viết Dockerfile để build image](../../../docs/docker-coban/docker-dockerfile.md).

## Làm theo

### Bước 1. Vào thư mục ứng dụng
Dockerfile của bạn nằm cùng chỗ với mã nguồn:
```sh
cd thuc-hanh/du-an-1-so-luu-but/ung-dung
```
Trong đó có 4 file: `app.py` (chương trình), `requirements.txt` (danh sách thư viện cần cài), `Dockerfile` (công thức), `.dockerignore` (danh sách file **không** đưa vào image).

### Bước 2. Đóng gói (build)
```sh
docker build -t so-luu-but-web:1.0 .
```
Dấu chấm `.` ở cuối nghĩa là "dùng thư mục hiện tại". Đừng quên nó.

**Bạn sẽ thấy:** Docker chạy từng bước theo Dockerfile (tải Python, cài thư viện, chép code). Lần đầu mất khoảng một đến hai phút.

### Bước 3. Xem thành quả
```sh
docker images so-luu-but-web
docker history so-luu-but-web:1.0
```
`docker images` cho thấy image bạn vừa tạo cùng dung lượng. `docker history` cho thấy **từng lớp** của image (mỗi dòng Dockerfile là một lớp).

### Bước 4. Đóng gói lần thứ hai: xem cái "bộ nhớ nhanh" (cache) làm việc
Chạy lại đúng lệnh ở bước 2.

**Bạn sẽ thấy:** xong gần như tức thì, vì Docker nhớ các bước đã làm.

Giờ mở `app.py`, thêm một dòng ghi chú (bắt đầu bằng `#`) ở đâu cũng được, rồi đóng gói lại. Lần này Docker **chỉ làm lại bước chép code**, còn bước cài thư viện (lâu nhất) vẫn dùng lại bản cũ. Đây là lý do trong Dockerfile ta cho cài thư viện **trước**, chép code **sau**.

### Bước 5. Chạy thử (chưa có redis)
```sh
docker run -d --name web -p 8000:8000 so-luu-but-web:1.0
```
Mở `http://localhost:8000`.

**Bạn sẽ thấy:** một khung **màu đỏ** ghi "Không kết nối được tới Redis". **Đó là kết quả đúng.** Ứng dụng chạy tốt nhưng cần "cuốn sổ" redis để ghi chép, mà ta chưa bật nó. Việc này sẽ làm ở giai đoạn 3.

Xem thêm:
```sh
docker logs web      # nhật ký của ứng dụng
docker ps            # sau khoảng 15-20 giây, cột STATUS sẽ có thêm chữ (healthy)
```
`(healthy)` nghĩa là "khỏe". Nhờ dòng `HEALTHCHECK` trong Dockerfile, cứ vài giây Docker lại hỏi ứng dụng "bạn còn ổn không?" và ứng dụng trả lời "ổn".

## Đọc hiểu Dockerfile từng dòng

Mở file `ung-dung/Dockerfile` và đối chiếu với bảng này. Hãy hình dung đây là **công thức nấu ăn**: làm từ trên xuống dưới.

| Dòng trong Dockerfile | Nghĩa dễ hiểu | Vì sao cần |
|---|---|---|
| `FROM python:3.12-slim` | "Bắt đầu từ một căn bếp có sẵn Python 3.12 bản gọn nhẹ." | Mình không tự cài Python từ con số 0. Ghi rõ số phiên bản `3.12`, **không** dùng `latest` để hôm nay hay năm sau build ra vẫn giống nhau |
| `ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1` | Hai công tắc cấu hình cho Python | Cái đầu: không sinh file rác. Cái sau: in nhật ký **ngay lập tức** để `docker logs` thấy liền |
| `WORKDIR /app` | "Từ giờ làm việc trong thư mục /app" (chưa có thì tự tạo) | Mọi lệnh sau đó chạy ở đây, đỡ phải gõ đường dẫn dài |
| `COPY requirements.txt .` | Chép **riêng** file danh sách thư viện vào | Chép riêng để tận dụng "bộ nhớ nhanh": thư viện hiếm khi đổi |
| `RUN pip install --no-cache-dir -r requirements.txt` | Cài các thư viện trong danh sách | `--no-cache-dir` bảo pip đừng giữ file tải về, image nhẹ hơn |
| `COPY app.py .` | Chép chương trình vào | Chép **sau cùng** vì file này đổi liên tục |
| `RUN useradd --system --create-home app` | Tạo một tài khoản thường tên `app` | Chạy bằng tài khoản thường an toàn hơn chạy bằng "quản trị tối cao" |
| `USER app` | "Từ giờ mọi thứ chạy dưới tên `app`" | Lỡ ứng dụng bị tấn công thì kẻ xấu cũng chỉ có quyền thấp |
| `EXPOSE 8000` | Ghi chú: "chương trình này nghe ở cổng 8000" | Chỉ là **ghi chú** cho người đọc, chưa tự mở cửa ra ngoài. Việc mở cửa là do `-p` khi chạy |
| `HEALTHCHECK ... CMD python -c "..."` | Cứ 15 giây tự hỏi ứng dụng "còn ổn không?" bằng cách gọi đường `/health` | Docker biết container **thật sự khỏe** hay chỉ mới "đang chạy" |
| `CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]` | Lệnh để **khởi động ứng dụng** khi container chạy | `gunicorn` là chương trình phục vụ web ổn định. Viết dạng danh sách `[...]` để Docker nhận được lệnh "dừng lại" đúng cách |

**Vì sao thứ tự dòng quan trọng?** Docker xây image theo từng lớp, mỗi dòng là một lớp, và nhớ kết quả từng lớp. Nếu một lớp đổi thì **mọi lớp bên dưới nó phải làm lại**. Nên ta xếp thứ gì ít đổi lên trên (cài thư viện), thứ hay đổi xuống dưới (chép code).

**`.dockerignore` để làm gì?** Là danh sách những thứ **không** đem vào image, như `.git`, file tạm, file mật khẩu `.env`. Vừa nhẹ hơn, vừa không lỡ làm rò mật khẩu.

## Tự kiểm tra
1. Tại sao `COPY requirements.txt` đứng trước `COPY app.py`?
2. Cái gì xảy ra nếu bạn xóa dòng `USER app`? Container có chạy được không? Có còn an toàn như trước không?
3. `EXPOSE 8000` có tự làm trình duyệt vào được cổng 8000 không? Điều gì mới làm được việc đó?

## Dọn dẹp trước khi sang giai đoạn sau
```sh
docker rm -f web
```
(Giữ lại image `so-luu-but-web:1.0`, giai đoạn sau còn dùng.)

## Vấn đề còn lại, dẫn sang giai đoạn 3
Ứng dụng cần redis mà chưa có. Ta sẽ bật redis lên, rồi cho hai container **nói chuyện với nhau**. Đó là [giai đoạn 3](../giai-doan-3-noi-mang-bang-tay/README.md).
