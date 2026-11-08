# Giai đoạn 6: Vận hành - theo dõi, giới hạn, sửa code thấy ngay, dọn dẹp

## Ở giai đoạn này bạn học gì?
Hệ thống đã chạy. Giai đoạn này dạy bạn **sống chung với nó**: biết nó đang làm gì, biết khi nó hỏng thì xem ở đâu, không để nó ăn hết máy, sửa code nhanh, và dọn sạch khi xong.

Đây là giai đoạn cuối của dự án 1. Chạy xong là bạn đã đi hết một vòng: từ một container lẻ đến một hệ thống nhiều phần có lễ tân, có mạng riêng, có ổ lưu dữ liệu.

## Làm theo

### Bước 1. Chạy bản hoàn chỉnh
```sh
cd thuc-hanh/du-an-1-so-luu-but/giai-doan-6-van-hanh
cp .env.example .env            # PowerShell: Copy-Item .env.example .env
docker compose config
docker compose up -d --build
docker compose ps
```
Nếu giai đoạn 5 vẫn đang chạy cũng không sao: đây là cùng một hệ thống (cùng `name: so-luu-but`) nên Compose chỉ cập nhật những gì khác. Mở `http://localhost:8080` để xem.

### Bước 2. Học cách "nhìn vào" hệ thống
```sh
docker compose logs -f web        # xem nhật ký của web, liên tục (bấm Ctrl+C để thoát)
docker compose logs --tail 20     # 20 dòng nhật ký cuối của tất cả dịch vụ
docker compose top                # các chương trình đang chạy trong từng container
docker stats                      # xem CPU và bộ nhớ từng container theo thời gian thực (Ctrl+C để thoát)
docker compose exec web sh        # bước vào bên trong container web
whoami                            # (gõ trong container) kết quả là "app", KHÔNG phải root. Đó là nhờ dòng USER trong Dockerfile
exit
```
Trong `docker stats`, cột `MEM USAGE / LIMIT` hiện giới hạn bộ nhớ (ví dụ `128MiB`). Đó là kết quả của mục `deploy.resources.limits` mới thêm.

### Bước 3. Phá thử có chủ đích (cách học nhớ lâu nhất)
```sh
docker compose stop redis
```
Tải lại trang.

**Bạn sẽ thấy:** khung đỏ "Không kết nối được tới Redis" nhưng **trang vẫn sống**, web không sập. Xem `docker compose ps`: `web` vẫn chạy, `redis` đã dừng.

```sh
docker compose start redis
```
Tải lại trang.

**Bạn sẽ thấy:** hệ thống tự hồi phục, dữ liệu còn nguyên. Ứng dụng viết tốt là ứng dụng biết "báo lỗi nhẹ nhàng" thay vì sập.

### Bước 4. Sửa code thấy ngay (Compose Watch)
```sh
docker compose watch
```
Lệnh này **không trả lại dòng lệnh**, nó đứng canh. Mở file `../ung-dung/app.py`, tìm chữ `Container phục vụ` rồi đổi thành chữ khác, **lưu lại**.

**Bạn sẽ thấy:** trong cửa sổ `watch` hiện dòng chép file, web tự khởi động lại, tải lại trang là thấy chữ mới. Không cần đóng gói lại thủ công. Bấm `Ctrl+C` để thoát (container vẫn chạy). Nhớ đổi chữ về như cũ.

> Cần Compose phiên bản 2.23 trở lên. Kiểm tra bằng `docker compose version`.

### Bước 5. Dọn dẹp sạch sẽ
```sh
docker compose down -v --rmi local     # xóa container, mạng, ổ lưu dữ liệu và image tự đóng gói
docker system df                       # xem Docker còn chiếm bao nhiêu dung lượng ổ cứng
docker image prune                     # xóa các image "mồ côi" không còn dùng
```

## Đọc hiểu phần MỚI trong `compose.yaml`

| Chỗ | Là gì | Giải thích dễ hiểu |
|---|---|---|
| `x-nhat-ky: &nhat-ky` ... và `<<: *nhat-ky` | Viết một lần, dùng nhiều chỗ | `&nhat-ky` là **dán nhãn** cho một đoạn cấu hình. `<<: *nhat-ky` là **chép đoạn đó vào đây**. Giống như soạn một mẫu rồi dán vào ba nơi, sửa mẫu một lần thì cả ba cùng đổi. Tên bắt đầu bằng `x-` để Compose hiểu "đây chỉ là mẫu, không phải dịch vụ" |
| `logging: ... max-size: "10m"` `max-file: "3"` | Giới hạn nhật ký | Nhật ký (log) cứ ghi mãi sẽ làm đầy ổ cứng. Đặt: mỗi file tối đa 10 MB, giữ 3 file |
| `deploy: resources: limits: cpus: "0.50"` | Giới hạn CPU | Container chỉ được dùng tối đa nửa lõi CPU. Con số để trong **ngoặc kép** |
| `deploy: resources: limits: memory: 128M` | Giới hạn bộ nhớ | Quá 128 MB thì container bị dừng thay vì kéo cả máy chậm theo. `M` là megabyte |
| `develop: watch:` | Chế độ canh file | Mỗi mục trong `watch` là một luật "file này đổi thì làm việc kia" |
| `action: sync+restart` | Chép file rồi khởi động lại | Dùng cho file code: chép file mới vào container và bật lại chương trình |
| `action: rebuild` | Đóng gói lại image | Dùng khi đổi danh sách thư viện, vì phải cài thư viện mới |
| `path:` và `target:` | Từ đâu, đến đâu | `path` = file trên máy bạn; `target` = chỗ đặt file bên trong container |

## Tự kiểm tra
1. Nhật ký không giới hạn thì có thể gây ra chuyện gì sau vài tháng chạy?
2. Vì sao dùng `docker compose stop redis` rồi trang vẫn hiện (khung lỗi) mà không sập hẳn? *(Gợi ý: nhìn đoạn code xử lý lỗi trong `app.py`.)*
3. Giới hạn bộ nhớ 128 MB có ý nghĩa gì với máy chủ chạy nhiều ứng dụng?
4. `docker compose down` khác `docker compose down -v` ở đâu? Lần nào nên dùng lần nào?

## Bạn đã làm được gì ở dự án 1?
- Chạy container có sẵn (giai đoạn 1) và đóng gói ứng dụng của mình (2).
- Nối nhiều container qua mạng riêng, giữ dữ liệu bằng volume (3).
- Viết cả hệ thống trong một file YAML (4), thêm lễ tân và chia khu mạng (5).
- Theo dõi, giới hạn, sửa nhanh, dọn dẹp (6).

Đây là nền tảng. Bước tiếp theo là làm điều tương tự cho **một web đầy đủ**: có giao diện, máy chủ xử lý, cơ sở dữ liệu thật, mật khẩu, sao lưu và tự động hóa. Mời sang [Dự án 2](../../du-an-2-dong-goi-web-hoan-chinh/README.md).

## Bài tập thêm (nếu còn hứng)
1. Đổi tiêu đề và cổng chỉ bằng file `.env`, không sửa `compose.yaml`.
2. Nâng giới hạn bộ nhớ của `web` lên 256M, chạy lại và kiểm tra bằng `docker stats`.
3. Thử đóng gói theo cách "nhiều giai đoạn" (multi-stage) để image nhỏ hơn: xem mục 3.19 trong [bài Dockerfile](../../../docs/docker-coban/03-image-va-dockerfile/docker-dockerfile.md).
4. Quét lỗ hổng của image: `docker scout quickview so-luu-but-web:1.0` (hoặc dùng Trivy).
