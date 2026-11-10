# Bài tập sửa lỗi: tự tìm và sửa hệ thống bị phá

Đọc và làm theo hướng dẫn thì ai cũng làm được. Nhưng khi **hệ thống hỏng thật** mới là lúc bạn học nhiều nhất. Bài tập này tự **phá hệ thống "Sổ lưu bút" một cách có kiểm soát**, rồi để bạn tự tìm lỗi và sửa.

Làm sau khi xong [Dự án 1](../du-an-1-so-luu-but/README.md) (nhất là giai đoạn 4 đến 6).

## An toàn: nó phá cái gì, không phá cái gì

| Có đụng tới | Không đụng tới |
|---|---|
| Một **bản sao** của hệ thống trong thư mục `lab/` (nằm cạnh `lab.sh`) | Các file thật của dự án 1 và dự án 2 |
| Tài nguyên Docker mang tên **`loi-lab`**: dự án Compose `loi-lab`, image `loi-lab-web:1.0`, container `loi-lab-blocker` | Các container, image, volume, network khác của bạn (như `portfolio`, `data-lakehouse`...) |
| Cổng **8090** của máy | Cổng khác |

Script từ chối xóa bất kỳ thư mục nào không do chính nó tạo ra. Dọn sạch mọi thứ bằng `bash lab.sh xoa`.

## Chuẩn bị (trong WSL)

1. **Docker chạy được trong WSL:** mở Docker Desktop, bật *Settings → Resources → WSL integration* cho bản Ubuntu của bạn. Kiểm tra trong WSL:
   ```sh
   docker --version
   docker compose version
   curl --version
   ```
   Thiếu `curl` thì `sudo apt install -y curl`.
2. **Cổng 8090 trống** (không chương trình nào dùng).
3. **Vào thư mục bài tập.** Ổ D của Windows nằm ở `/mnt/d` trong WSL:
   ```sh
   cd /mnt/d/docker-docs/thuc-hanh/bai-tap-sua-loi
   bash lab.sh giup
   ```
   Luôn chạy bằng `bash lab.sh ...`, đừng dùng `./lab.sh` (ổ `/mnt` thường không giữ quyền thực thi).

## Một lượt chơi

```sh
bash lab.sh pha ngau-nhien     # 1. hệ thống bị phá ngẫu nhiên, script in đề bài (không nói lỗi gì)
cd "…/lab/he-thong"            # 2. vào thư mục làm bài (đường dẫn script đã in sẵn)
docker compose ps              # 3. tự điều tra, tự sửa file trong thư mục lab/
bash lab.sh kiem-tra           # 4. kiểm tra đã sửa xong chưa (chạy từ thư mục bai-tap-sua-loi)
bash lab.sh dap-an             # 5. đọc đáp án để đối chiếu cách nghĩ
```

Bí thì xin gợi ý theo từng nấc, từ nhẹ đến rõ: `bash lab.sh goi-y`, `goi-y 2`, `goi-y 3`. Muốn làm lại hay thử đề khác: `bash lab.sh lam-lai` hoặc `bash lab.sh pha ngau-nhien`.

**Luật chơi để học hiệu quả:**
1. Đừng mở thư mục `dap-an/` và đừng đọc phần `f01..f11` trong `lab.sh`. Hai chỗ đó chứa đáp án.
2. Tự đặt giờ giới hạn (ví dụ 15 phút cho đề Dễ, 30 phút cho đề Khó) rồi mới xin gợi ý.
3. Sau khi sửa xong, **hãy đọc đáp án** để chắc bạn hiểu *vì sao*, không chỉ *sửa thế nào*.
4. Sửa xong thì làm một đề ngẫu nhiên khác. Làm khoảng 5 đề, bạn sẽ thấy mình nhìn lỗi nhanh hơn rõ rệt.

## Phương pháp tìm lỗi (5 bước, đi theo thứ tự)

```
1. QUAN SÁT   → Cái gì đang chạy, cái gì không? Trạng thái ra sao?
2. ĐỌC LOG    → Chương trình tự nói gì về lỗi của nó?
3. KIỂM CẤU HÌNH → Giá trị Compose thực sự dùng có đúng ý mình không?
4. KHOANH VÙNG → Lỗi nằm ở phần nào: ngoài hay trong, dịch vụ nào, bước nào?
5. SỬA MỘT CHỖ, THỬ LẠI → Sửa từng thay đổi nhỏ, kiểm tra lại, đừng sửa nhiều thứ cùng lúc
```

| Bước | Lệnh hữu ích (chạy trong `lab/he-thong`) |
|---|---|
| Quan sát | `docker compose ps`, `docker compose ps -a`, `docker ps -a` |
| Đọc log | `docker compose logs --tail 50 <dịch vụ>`, `docker compose logs -f` |
| Kiểm cấu hình | `docker compose config`, `docker compose config \| grep -n ports -A3` |
| Khoanh vùng | `docker compose exec <dịch vụ> sh`, `docker inspect <container>`, `docker port <container>`, `curl -i http://localhost:8090` |
| Sửa và thử lại | `docker compose up -d --build` (có `--build` khi đã sửa Dockerfile hoặc code) |

Hai câu hỏi hữu ích khi bí: *"Lần cuối nó chạy đúng là khi nào và sau đó đã đổi gì?"* và *"Nó đang làm đúng điều mình nghĩ không, hay chỉ trông như vậy?"*

## Danh sách đề

Chỉ liệt kê mức độ và kỹ năng luyện, không tiết lộ nguyên nhân (xem bằng `bash lab.sh danh-sach`).

| Đề | Mức | Kỹ năng luyện |
|---|---|---|
| 1 | Dễ | quan sát trạng thái hệ thống một cách cẩn thận |
| 2 | Dễ | đọc thông báo lỗi khi kiểm tra file cấu hình |
| 3 | Dễ | đọc thông báo lỗi khi tải image |
| 4 | Dễ | tìm hiểu thứ gì đang chiếm tài nguyên của máy |
| 5 | Vừa | so sánh giá trị mong đợi với giá trị thực tế |
| 6 | Vừa | đọc thông báo lỗi khi kiểm tra file cấu hình |
| 7 | Vừa | đọc nhật ký ứng dụng và nội dung trang lỗi |
| 8 | Vừa | đọc nhật ký của từng container |
| 9 | Khó | tìm hiểu vì sao một container không "khỏe" |
| 10 | Khó | phân tích khi mọi thứ trông bình thường mà vẫn lỗi |
| 11 | Vừa | đọc lỗi khi đóng gói image |

## Cấu trúc thư mục

```
bai-tap-sua-loi/
├── README.md        ← bài này
├── lab.sh           ← script điều khiển (pha, kiem-tra, goi-y, dap-an, lam-lai, xoa...)
├── mau/             ← bản MẪU khỏe mạnh, dùng để tạo bản sao sạch mỗi lần
│   ├── he-thong/      compose.yaml, nginx/default.conf, env.mau
│   └── ung-dung/      app.py, Dockerfile, requirements.txt
├── dap-an/          ← 11 file gợi ý và đáp án (đừng mở nếu muốn tự làm)
└── lab/             ← bản sao bị phá (tự sinh ra, không đưa lên git)
```

`mau/` là bản chép riêng của ứng dụng sổ lưu bút. Vì vậy các lỗi luôn áp dụng đúng, kể cả khi bạn đã sửa dự án 1 của mình.

## Gỡ rối khi chạy script trong WSL

| Triệu chứng | Nguyên nhân | Cách xử lý |
|---|---|---|
| `$'\r': command not found` hoặc `syntax error near unexpected token` | File `lab.sh` bị đổi xuống dòng kiểu Windows (CRLF) | `sed -i 's/\r$//' lab.sh` (hoặc `dos2unix lab.sh`), rồi chạy lại. Repo đã có `.gitattributes` ép LF cho file `.sh` |
| `docker: command not found` | Docker Desktop chưa bật tích hợp WSL | Bật *WSL integration* cho bản Ubuntu, mở lại terminal |
| `Cannot connect to the Docker daemon` | Docker Desktop chưa chạy | Mở Docker Desktop và đợi báo đang chạy |
| `lam-lai` báo hệ thống chưa lên | Cổng 8090 đang bị chương trình khác giữ | `docker ps --filter publish=8090` và `ss -ltnp \| grep 8090`, giải phóng cổng rồi thử lại |
| Chạy chậm | Thư mục trên ổ Windows (`/mnt/d`) truy cập chậm hơn ổ Linux | Đặt thư mục làm bài trong ổ Linux: `LAB_DIR=$HOME/loi-lab bash lab.sh pha ngau-nhien` (nhớ dùng cùng `LAB_DIR` cho các lệnh sau) |
| `lab.sh` báo "file mẫu không còn chuỗi cần thay" | Trình soạn thảo tự định dạng lại file trong `mau/` (ví dụ thêm dấu cách trong `[ ... ]`) hoặc bạn lỡ sửa file mẫu | Chạy `bash lab.sh tu-kiem-tra` để biết đề nào hỏng, rồi khôi phục mẫu: `git checkout -- mau` (hoặc tắt "format on save" cho thư mục này) |
| Thông báo lỗi hơi khác đáp án | Mỗi phiên bản Docker/Compose diễn đạt khác chút | Bình thường. Hãy đọc ý nghĩa, đừng so từng chữ |

## Bài tập nâng cao (tự làm sau khi xong cả 11 đề)

1. **Tự phá rồi đố người khác:** thêm một đề `f12` bằng cách sửa một chỗ khác trong `mau/` (hàm `thay` trong `lab.sh` giúp thay đúng một chuỗi), viết file `dap-an/12.md`, rồi nhờ bạn bè giải.
2. **Chẩn đoán trên dự án 2:** áp dụng 5 bước ở trên cho [Dự án 2](../du-an-2-dong-goi-web-hoan-chinh/README.md), thử tự phá một chỗ (ví dụ đổi mật khẩu trong `bi-mat/`) rồi điều tra.
3. **Viết "sổ tay lỗi":** mỗi lần sửa xong, ghi lại 3 dòng: *triệu chứng, nguyên nhân, cách phát hiện*. Sau vài tuần bạn có tài liệu riêng quý hơn mọi bài hướng dẫn.
