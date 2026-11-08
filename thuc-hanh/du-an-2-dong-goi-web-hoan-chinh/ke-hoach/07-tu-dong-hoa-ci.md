# Bước 7: Tự động hóa kiểm tra và đóng gói (CI)

## Mục tiêu
Mỗi lần bạn đẩy code lên, **một máy tự động** làm giúp: dựng cả hệ thống, thử gọi vài lần, và đóng gói image đem cất lên kho. Người làm việc nhóm không còn phải nhớ "nhớ chạy thử trước khi gộp nhé".

CI là chữ viết tắt của *Continuous Integration* (tích hợp liên tục). Hiểu đơn giản: **dây chuyền kiểm hàng tự động**.

## Vì sao cần?
| Không có CI | Có CI |
|---|---|
| "Chạy được trên máy tôi" nhưng hỏng trên máy người khác | Mọi lần kiểm tra đều chạy trên một máy sạch giống nhau |
| Quên thử trước khi đẩy code lên | Máy luôn thử, hỏng là báo đỏ ngay |
| Đóng gói thủ công, mỗi người một kiểu, tên phiên bản lộn xộn | Image tự đóng gói, tự gắn nhãn phiên bản theo quy tắc |

## Làm gì

### 7.1 Đọc file mẫu
Mở [`ci/github-actions-mau.yml`](../ci/github-actions-mau.yml). Đây là mẫu cho **GitHub Actions**. File có ghi chú từng dòng; bảng dưới là bản đồ.

| Khối trong file | Làm gì |
|---|---|
| `on:` | **Khi nào chạy**: đẩy code lên nhánh `main`, gắn nhãn phát hành `v1.0.0`, hoặc có yêu cầu gộp code |
| `permissions:` | Quyền tối thiểu cho "chìa khóa" tự động của GitHub (chỉ đọc code, được đẩy image) |
| Việc `kiem-tra` | Dựng cả hệ thống bằng Compose, đợi khỏe, gọi thử API qua nginx. Hỏng là dừng |
| Việc `dong-goi` | Đóng gói hai image (`api`, `frontend`) rồi đẩy lên kho `ghcr.io`. Có `needs: kiem-tra` nên **chỉ chạy khi kiểm tra đã qua** |
| `strategy.matrix.phan: [api, frontend]` | Chạy việc `dong-goi` hai lần, mỗi lần một phần. Viết một lần, ra hai việc |
| `docker/metadata-action` | Tự sinh nhãn phiên bản: tên nhánh, số phiên bản (khi gắn tag `v1.2.3`), mã commit |
| `cache-from / cache-to: type=gha` | Dùng lại bộ nhớ nhanh của lần trước cho đóng gói nhanh hơn |

### 7.2 Dùng thử (nếu bạn có repo trên GitHub)
1. Sao chép file mẫu thành `.github/workflows/dong-goi.yml` ở **gốc repo**.
2. Nếu bạn đặt dự án ở thư mục khác, sửa `THU_MUC_DU_AN` và `working-directory` trong file.
3. Đẩy lên nhánh. Vào tab **Actions** trên GitHub: sẽ thấy việc đang chạy.
4. Để phát hành một phiên bản: `git tag v1.0.0 && git push origin v1.0.0`. Image sẽ có nhãn `1.0.0`.

> Nếu repo của bạn là dự án học này (không phải ứng dụng thật), CI mẫu vẫn chạy được nhưng bạn có thể không muốn đẩy image lên. Khi đó cứ để nó chỉ chạy việc `kiem-tra`.

### 7.3 Không có GitHub? Chạy "CI" bằng tay trên máy bạn
Việc `kiem-tra` chính là chuỗi lệnh bạn có thể gõ tay. Hãy làm quen:
```sh
cp .env.example .env
sh bi-mat/tao-bi-mat.sh
docker compose config -q
docker compose up -d --build --wait --wait-timeout 120
curl -fsS http://localhost:8080/api/health
curl -fsS -X POST http://localhost:8080/api/tasks -H 'Content-Type: application/json' -d '{"title":"viec thu nghiem"}'
curl -fsS http://localhost:8080/api/tasks
docker compose down -v
```
(`--wait` đợi mọi dịch vụ khỏe mới đi tiếp. `curl -f` làm lệnh thất bại nếu máy chủ trả mã lỗi.) Trên PowerShell dùng `curl.exe` thay cho `curl` và đặt dấu nháy kép cho phần JSON.

### 7.4 Những kiểm tra nên thêm dần
| Kiểm tra | Công cụ gợi ý |
|---|---|
| Quét lỗ hổng trong image | `docker scout cves <image>`, Trivy |
| Kiểm tra lỗi trong Dockerfile | hadolint |
| Kiểm tra code Python | ruff, pytest |
| Kiểm tra file YAML | `docker compose config -q` (đã có), yamllint |

## Lưu ý về bí mật trong CI
- Mật khẩu dùng khi thử là mật khẩu **ngẫu nhiên tạo ngay trong lần chạy**, rồi bỏ đi. Không dùng mật khẩu thật của máy chủ.
- Mật khẩu thật (ví dụ khóa để đăng nhập máy chủ khi triển khai tự động) đặt trong **Settings → Secrets** của repo, không bao giờ viết vào file trong repo.

## Kiểm tra (bạn đã xong bước 7 khi…)
- [ ] Bạn đã chạy được chuỗi lệnh ở 7.3 từ đầu đến cuối mà không lỗi.
- [ ] Bạn nói được vì sao việc `dong-goi` có `needs: kiem-tra`.
- [ ] Bạn đọc hiểu file mẫu (hoặc đã chạy nó trên GitHub).

## Bài tập
Thêm một bước vào việc `kiem-tra` để **kiểm tra rằng `db` không mở cổng ra ngoài**: ví dụ dùng `docker compose port db 5432` và mong đợi nó không trả về địa chỉ nào. Viết bước đó dưới dạng một khối `- name: ... run: ...`.

Tiếp theo: [Bước 8: Đưa lên máy chủ](08-trien-khai-len-may-chu.md)
