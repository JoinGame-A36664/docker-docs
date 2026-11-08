# Dockerfile của phần giao diện: nginx + các file HTML/CSS/JS.
# Ngắn gọn vì giao diện chỉ là file tĩnh, không cần "xưởng" cài đặt gì.

# Image nginx bản gọn nhẹ, ghi rõ phiên bản.
FROM nginx:1.27-alpine

# Thay cấu hình mặc định bằng cấu hình của mình.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Chép giao diện vào chỗ nginx đọc.
COPY public/ /usr/share/nginx/html/

# Cứ 15 giây hỏi nginx "còn sống không" qua đường /healthz.
# Dùng 127.0.0.1 thay vì "localhost" để tránh nhầm sang địa chỉ IPv6.
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz > /dev/null || exit 1
