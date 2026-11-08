#!/bin/sh
# Tạo mật khẩu ngẫu nhiên cho cơ sở dữ liệu và lưu vào file bi-mat/db_password.txt.
# Chạy từ thư mục dự án:   sh bi-mat/tao-bi-mat.sh
set -e
cd "$(dirname "$0")"

if [ -f db_password.txt ]; then
  echo "Da co db_password.txt, KHONG ghi de (de tranh mat mat khau cua co so du lieu dang chay)."
  exit 0
fi

# Lấy 24 ký tự ngẫu nhiên gồm chữ và số (chỉ chữ và số để khỏi lỗi vì ký tự đặc biệt).
LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24 > db_password.txt

# Vì sao 644 (mọi người trên máy chủ đều ĐỌC được file) mà không phải 600?
# Container chạy bằng tài khoản khác tài khoản của bạn, nếu để 600 nó sẽ báo "Permission denied".
# Bù lại ta khóa cả thư mục (700): người khác trên máy chủ không vào được thư mục này.
chmod 644 db_password.txt
chmod 700 .

echo "Da tao bi-mat/db_password.txt. KHONG dua file nay len git."
