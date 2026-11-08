#!/bin/sh
# Khôi phục cơ sở dữ liệu từ một file sao lưu.
# Chạy từ thư mục dự án:   sh sao-luu/khoi-phuc.sh sao-luu/appdb_20250101_120000.sql.gz
# CẢNH BÁO: lệnh này XÓA dữ liệu hiện tại trong bảng "tasks" rồi nạp lại từ file sao lưu.
set -e

FILE="$1"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Cach dung: sh sao-luu/khoi-phuc.sh <duong-dan-file.sql.gz>"
  exit 1
fi

printf "Se XOA du lieu hien tai va nap lai tu %s. Go 'dong y' de tiep tuc: " "$FILE"
read XAC_NHAN
[ "$XAC_NHAN" = "dong y" ] || { echo "Da huy."; exit 1; }

# 1) Xóa bảng cũ. 2) Nạp lại từ file. "-T" = không dùng cửa sổ giả lập, cần khi đưa dữ liệu vào bằng dấu |
docker compose exec -T db psql -U app -d appdb -v ON_ERROR_STOP=1 -c "DROP TABLE IF EXISTS tasks;"
gunzip -c "$FILE" | docker compose exec -T db psql -U app -d appdb -v ON_ERROR_STOP=1

echo "Khoi phuc xong."
