# Giai đoạn 3: Nối hai container bằng tay (mạng riêng + ổ lưu dữ liệu)

## Ở giai đoạn này bạn học gì?
Hai ý, nhưng gắn liền nhau:
1. **Mạng riêng (network):** cho `web` và `redis` nói chuyện với nhau, gọi nhau bằng **tên**.
2. **Ổ lưu dữ liệu (volume):** để dữ liệu của redis **không mất** khi container bị xóa.

Giai đoạn này cố ý bắt bạn **gõ lệnh bằng tay**. Bạn sẽ thấy nó dài và dễ sai. Đó là để giai đoạn 4 trông thật "đã" khi mọi thứ gói gọn trong một file.

Đọc thêm nếu thích: [Network trong Docker](../../../docs/docker-coban/05-network/docker-network.md), [Volume trong Docker](../../../docs/docker-coban/04-volume-va-du-lieu/docker-volume.md).

> Cần có sẵn image `so-luu-but-web:1.0` từ giai đoạn 2. Kiểm tra bằng `docker images so-luu-but-web`. Chưa có thì quay lại giai đoạn 2.

## Làm theo

### Bước 1. Tạo mạng riêng
```sh
docker network create mang-so-luu-but
```
Hình dung: bạn vừa lắp một **hệ thống điện thoại nội bộ**. Ai được cắm vào mạng này thì gọi nhau bằng tên.

### Bước 2. Bật redis, cắm vào mạng đó
```sh
docker run -d --name redis --network mang-so-luu-but redis:7-alpine
```
Tên container là `redis`. Tên này chính là "số máy nội bộ" để web gọi tới.

### Bước 3. Bật web, cũng cắm vào mạng đó
```sh
docker run -d --name web --network mang-so-luu-but -e REDIS_HOST=redis -p 8000:8000 so-luu-but-web:1.0
```
**Mở** `http://localhost:8000`.

**Bạn sẽ thấy:** khung đỏ biến mất. Trang đếm lượt xem, có ô nhập lời nhắn. Gõ vài dòng rồi bấm "Gửi". Tải lại trang, số lượt xem tăng lên.

Phần mới là `--network mang-so-luu-but` (cắm vào mạng) và `-e REDIS_HOST=redis` (dặn ứng dụng: *"cuốn sổ ở máy tên là `redis`"*). Ứng dụng đọc dòng dặn này để biết gọi ai.

### Bước 4. Thí nghiệm "mất sạch dữ liệu"
Xóa redis đi rồi bật lại y như cũ:
```sh
docker rm -f redis
docker run -d --name redis --network mang-so-luu-but redis:7-alpine
```
Tải lại `http://localhost:8000`.

**Bạn sẽ thấy:** số lượt xem về 1 và **mọi lời nhắn biến mất**. Lý do: dữ liệu nằm **bên trong** container. Container bị xóa thì dữ liệu mất theo, như nhà bị phá thì đồ đạc mất.

### Bước 5. Sửa lỗi bằng volume
Bây giờ gắn "ngăn kéo để ngoài sân" cho redis:
```sh
docker rm -f redis
docker run -d --name redis --network mang-so-luu-but -v du-lieu-redis:/data redis:7-alpine redis-server --appendonly yes
```
Gõ vài lời nhắn trên trang. Rồi lặp lại thí nghiệm xóa:
```sh
docker rm -f redis
docker run -d --name redis --network mang-so-luu-but -v du-lieu-redis:/data redis:7-alpine redis-server --appendonly yes
```
Tải lại trang.

**Bạn sẽ thấy:** lời nhắn **vẫn còn**. Xem ổ lưu trữ bằng `docker volume ls` sẽ thấy tên `du-lieu-redis`.

Giải thích hai chỗ mới:
- `-v du-lieu-redis:/data`: nối ổ lưu trữ tên `du-lieu-redis` (do Docker quản lý) vào thư mục `/data` bên trong container. Redis ghi dữ liệu vào `/data` nên thực chất ghi vào ổ bên ngoài.
- `redis-server --appendonly yes`: dặn redis **ghi lại từng thao tác ra đĩa**. Mặc định nó chủ yếu giữ trong bộ nhớ nên cần dặn thêm để dữ liệu thật sự nằm trong `/data`.

## Bảng đọc hiểu các lệnh mới

| Lệnh / phần | Nghĩa dễ hiểu |
|---|---|
| `docker network create mang-so-luu-but` | Tạo một mạng nội bộ có tên `mang-so-luu-but` |
| `--network mang-so-luu-but` | Cắm container này vào mạng đó. Hai container **cùng mạng** mới gọi nhau bằng tên được |
| `-e REDIS_HOST=redis` | `-e` là *environment* (môi trường). Truyền cho chương trình một giá trị: biến `REDIS_HOST` bằng `redis` |
| `-v du-lieu-redis:/data` | Nối ổ lưu `du-lieu-redis` vào thư mục `/data` trong container |
| `docker volume ls` | Liệt kê các ổ lưu dữ liệu |
| `docker network ls` | Liệt kê các mạng |

## Tự kiểm tra
1. Thử bật `web` mà **không** có `--network mang-so-luu-but`. Trang hiện gì? Vì sao? *(Gợi ý: web sẽ gọi "redis" nhưng không nằm cùng mạng, nên không tìm thấy.)*
2. `-v du-lieu-redis:/data` khác `-v ./thu-muc:/data` ở điểm nào? *(Xem lại từ điển: volume và bind mount.)*
3. Bạn đã phải gõ bao nhiêu lệnh dài để chạy được hai container? Nếu hệ thống có 10 container thì sao?

## Dọn dẹp trước khi sang giai đoạn sau
**Linux / macOS / Git Bash:**
```sh
sh don-dep.sh
```
**Windows PowerShell:**
```powershell
./don-dep.ps1
```
Hoặc gõ tay:
```sh
docker rm -f web redis
docker network rm mang-so-luu-but
docker volume rm du-lieu-redis
```

## Vấn đề còn lại, dẫn sang giai đoạn 4
Mỗi lần chạy phải gõ 3 lệnh dài, thứ tự phải đúng, tên phải nhớ, sai một chữ là hỏng. Nếu có 10 container thì quá sức. Cách chuyên nghiệp là **viết tất cả vào một file**. Đó là [giai đoạn 4](../giai-doan-4-compose/README.md).
