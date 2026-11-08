# ============================================================
# Dockerfile của API - kiểu "hai giai đoạn" (multi-stage)
# Ý tưởng: dùng một "xưởng" để chuẩn bị đồ, rồi chỉ chuyển SẢN PHẨM sang "căn nhà" sạch sẽ để ở.
# Image cuối không chứa công cụ cài đặt thừa, nên nhỏ hơn và ít rủi ro hơn.
# ============================================================

# ---------- GIAI ĐOẠN 1: "xưởng" - cài thư viện vào một thư mục riêng ----------
# "AS build" = đặt tên cho giai đoạn này là "build" để giai đoạn sau gọi lại.
FROM python:3.12-slim AS build

WORKDIR /build

# Tạo một "môi trường ảo" Python tại /opt/venv: toàn bộ thư viện sẽ nằm gọn trong thư mục này.
RUN python -m venv /opt/venv
# Đặt đường dẫn ưu tiên để các lệnh sau dùng Python/pip trong /opt/venv.
ENV PATH="/opt/venv/bin:$PATH"

# Chép riêng danh sách thư viện trước để tận dụng "bộ nhớ nhanh" (cache): ít đổi nên đỡ phải cài lại.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------- GIAI ĐOẠN 2: "căn nhà" - image thật sự sẽ chạy ----------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Chỉ lấy thư mục thư viện đã cài sẵn từ giai đoạn "build". Công cụ cài đặt không đi theo sang đây.
COPY --from=build /opt/venv /opt/venv

# Chép mã nguồn sau cùng (phần hay thay đổi nhất).
COPY app.py .

# Chạy bằng tài khoản thường, không dùng quản trị tối cao.
RUN useradd --system --no-create-home app
USER app

EXPOSE 8000

# Cứ 15 giây tự hỏi API "khỏe không" bằng cách gọi /api/health (Python tự gọi, vì image gọn không có curl).
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/api/health', timeout=2)" || exit 1

# Khởi động bằng gunicorn (chương trình phục vụ web ổn định). Viết dạng danh sách [...] để nhận lệnh dừng đúng cách.
# --worker-tmp-dir /dev/shm: cho gunicorn ghi file tạm vào bộ nhớ, để chạy được cả khi hệ thống file chỉ đọc.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--worker-tmp-dir", "/dev/shm", "app:app"]
