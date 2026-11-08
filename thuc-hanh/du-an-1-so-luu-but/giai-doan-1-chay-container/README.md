# Giai đoạn 1: Chạy container đầu tiên

## Ở giai đoạn này bạn học gì?
Chỉ **một ý**: dùng lệnh `docker run` để chạy một chương trình có sẵn trong một "hộp" (container), rồi mở nó trên trình duyệt.

Chương trình bạn chạy là **nginx**, một phần mềm chuyên phát trang web. Bạn chưa phải viết gì cả.

Đọc thêm nếu thích: [Cài đặt docker](../../../docs/docker-5m/01.Caidatdocker.md), [Docker image](../../../docs/docker-coban/ghichep-docker-images.md).

## Làm theo

### Bước 1. Đứng đúng chỗ
Mở dòng lệnh và vào thư mục giai đoạn này:
```sh
cd thuc-hanh/du-an-1-so-luu-but/giai-doan-1-chay-container
```

### Bước 2. Chạy nginx và cho nó đọc trang web của bạn
**Linux / macOS / Git Bash:**
```sh
docker run -d --name trang-tinh -p 8080:80 -v "$(pwd)/trang-web:/usr/share/nginx/html:ro" nginx:1.27-alpine
```
**Windows PowerShell:**
```powershell
docker run -d --name trang-tinh -p 8080:80 -v "${PWD}/trang-web:/usr/share/nginx/html:ro" nginx:1.27-alpine
```

Lần đầu Docker sẽ **tải image nginx về** (cần Internet, mất vài chục giây). Các lần sau chạy gần như tức thì vì đã có sẵn trên máy.

### Bước 3. Mở trình duyệt
Vào `http://localhost:8080`.

**Bạn sẽ thấy:** dòng chữ "Xin chào từ container nginx!".

### Bước 4. Sửa trang web mà không cần chạy lại gì
Mở file `trang-web/index.html` bằng bất kỳ trình soạn thảo nào, sửa vài chữ, lưu lại, rồi **tải lại trang** trên trình duyệt.

**Bạn sẽ thấy:** nội dung đổi ngay. Vì thư mục `trang-web` của bạn được "gắn" thẳng vào container (đây gọi là *bind mount*, xem [từ điển](../../00-tu-dien-de-hieu.md)).

### Bước 5. Nhìn vào bên trong
```sh
docker ps                              # liệt kê các container đang chạy
docker logs trang-tinh                 # xem nhật ký của nó (mỗi lần bạn tải trang sẽ có thêm một dòng)
docker exec -it trang-tinh sh          # bước vào bên trong container
ls /usr/share/nginx/html               # (gõ trong container) thấy file index.html của bạn
exit                                   # thoát ra ngoài
```

## Giải thích từng phần của lệnh `docker run`

Hãy đọc lệnh như một câu nói: *"Docker ơi, chạy cho tôi một container…"*

| Phần | Nghĩa dễ hiểu |
|---|---|
| `docker run` | Tạo và chạy một container mới |
| `-d` | Chạy **ngầm** (không chiếm cửa sổ dòng lệnh của bạn). `d` là *detached* (tách ra) |
| `--name trang-tinh` | Đặt tên cho container để lần sau gọi cho dễ, nếu không Docker đặt tên ngẫu nhiên kỳ lạ |
| `-p 8080:80` | Làm **một cánh cửa**: cổng **8080 trên máy bạn** thông với cổng **80 bên trong container**. Số bên trái là của máy bạn, số bên phải là của container |
| `-v "...:/usr/share/nginx/html:ro"` | Gắn thư mục `trang-web` của bạn vào chỗ mà nginx đọc trang web. `:ro` là chỉ cho **đọc**, nginx không được sửa file của bạn |
| `nginx:1.27-alpine` | Tên image dùng để tạo container. Phần sau dấu `:` là phiên bản. `alpine` nghĩa là bản gọn nhẹ |

## Bạn sẽ thấy khi gõ `docker ps`
Một dòng có tên `trang-tinh`, cột `PORTS` ghi kiểu `0.0.0.0:8080->80/tcp` (nghĩa là "cổng 8080 của máy dẫn vào cổng 80 của container"), cột `STATUS` ghi `Up ...` (đang chạy). Số hiệu và thời gian của bạn sẽ khác.

## Tự kiểm tra
1. Nếu **bỏ** phần `-p 8080:80`, trình duyệt có vào được không? Vì sao? *(Gợi ý: nghĩ đến cái cánh cửa.)*
2. Gõ `docker rm -f trang-tinh` rồi chạy lại lệnh ở bước 2. Trang web có còn không? Dữ liệu thật sự nằm ở đâu? *(Gợi ý: container bị xóa, nhưng thư mục `trang-web`...)*
3. Muốn mở trang ở cổng 9090 thay vì 8080 thì sửa chỗ nào?

## Dọn dẹp trước khi sang giai đoạn sau
```sh
docker rm -f trang-tinh
```

## Vấn đề còn lại, dẫn sang giai đoạn 2
Bạn mới chạy **đồ làm sẵn của người khác**. Điều bạn thật sự muốn là chạy **ứng dụng của mình**. Muốn vậy phải biết cách *đóng gói* nó thành image. Đó là [giai đoạn 2](../giai-doan-2-dong-goi-ung-dung/README.md).
