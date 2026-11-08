# Dọn các thứ đã tạo ở giai đoạn 3. Chạy trong PowerShell: ./don-dep.ps1
# "2>$null" nghĩa là: nếu thứ đó không có sẵn thì im lặng bỏ qua.
docker rm -f web redis 2>$null
docker network rm mang-so-luu-but 2>$null
docker volume rm du-lieu-redis 2>$null
Write-Host "Da don xong giai doan 3."
