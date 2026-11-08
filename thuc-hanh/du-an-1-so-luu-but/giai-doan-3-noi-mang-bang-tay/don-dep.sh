#!/bin/sh
# Dọn các thứ đã tạo ở giai đoạn 3. Chạy: sh don-dep.sh
# Dấu "|| true" nghĩa là: nếu thứ đó không có sẵn thì bỏ qua, không báo lỗi.
docker rm -f web redis      2>/dev/null || true
docker network rm mang-so-luu-but 2>/dev/null || true
docker volume rm du-lieu-redis    2>/dev/null || true
echo "Da don xong giai doan 3."
