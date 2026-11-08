# Image gốc nhỏ, ghim phiên bản rõ ràng (không dùng "latest")
FROM python:3.12-slim

# Python không ghi file .pyc và in log ngay lập tức (để docker logs thấy ngay)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy file khai báo thư viện TRƯỚC rồi mới cài: sửa code không làm mất cache bước này
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy mã nguồn SAU CÙNG (phần hay thay đổi nhất)
COPY app.py .

# Không chạy bằng root
RUN useradd --system --create-home app
USER app

EXPOSE 8000

# Image slim không có curl, dùng chính Python để tự kiểm tra
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=2)" || exit 1

# Dạng exec (mảng JSON) để gunicorn là PID 1 và nhận được tín hiệu dừng
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
