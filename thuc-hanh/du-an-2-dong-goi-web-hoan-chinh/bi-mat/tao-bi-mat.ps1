# Tạo mật khẩu ngẫu nhiên cho cơ sở dữ liệu và lưu vào file bi-mat/db_password.txt.
# Chạy từ thư mục dự án (PowerShell):   ./bi-mat/tao-bi-mat.ps1
Set-Location $PSScriptRoot

if (Test-Path db_password.txt) {
    Write-Host "Da co db_password.txt, KHONG ghi de (de tranh mat mat khau cua co so du lieu dang chay)."
    exit 0
}

# 24 ký tự ngẫu nhiên gồm chữ và số.
$kyTu = [char[]](48..57 + 65..90 + 97..122)
$matKhau = -join (1..24 | ForEach-Object { $kyTu | Get-Random })

# -NoNewline: không thêm dấu xuống dòng ở cuối (nếu có, mật khẩu sẽ bị dư một ký tự).
Set-Content -Path db_password.txt -Value $matKhau -NoNewline -Encoding ascii

Write-Host "Da tao bi-mat/db_password.txt. KHONG dua file nay len git."
