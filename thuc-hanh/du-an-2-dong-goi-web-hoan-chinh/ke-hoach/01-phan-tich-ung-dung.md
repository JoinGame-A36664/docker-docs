# Bước 1: Phân tích ứng dụng (trước khi gõ bất kỳ lệnh Docker nào)

## Mục tiêu
Trả lời được: ứng dụng gồm **những phần nào**, mỗi phần **cần gì để chạy**, và **ai được nói chuyện với ai**. Làm bước này kỹ thì các bước sau gần như chỉ là viết ra giấy.

Người mới hay nhảy ngay vào viết Dockerfile rồi sau đó mới vỡ lẽ "à, phần này cần lưu dữ liệu", "à, phần kia cần mật khẩu". Đừng vậy.

## Làm gì

### 1.1 Liệt kê các phần
Hỏi: *nếu tắt máy này đi, mỗi phần sống ở đâu?* Với ứng dụng "Việc cần làm":

| Phần | Nó là gì | Chạy bằng cái gì | Cổng nó nghe |
|---|---|---|---|
| Giao diện | File HTML/CSS/JS để trình duyệt hiển thị | nginx | 80 |
| API | Chương trình xử lý (thêm, xóa, đổi trạng thái việc) | Python + gunicorn | 8000 |
| Cơ sở dữ liệu | Nơi lưu danh sách việc | PostgreSQL | 5432 |

**Quy tắc:** mỗi phần một container. Đừng nhét nhiều phần vào một container, vì sau này muốn cập nhật hay mở rộng một phần sẽ rất khó.

### 1.2 Với mỗi phần, trả lời 5 câu hỏi

| Câu hỏi | Giao diện | API | Cơ sở dữ liệu |
|---|---|---|---|
| Có cần **lưu dữ liệu lâu dài** không? | Không (file nằm sẵn trong image) | Không (mọi thứ ghi vào DB) | **Có** → cần volume |
| Có cần **mật khẩu / bí mật** không? | Không | **Có** (mật khẩu DB) | **Có** (đặt mật khẩu DB) |
| Ai được **gọi** nó? | Trình duyệt người dùng | Chỉ giao diện (nginx) | Chỉ API |
| Có cần **ra Internet** không? | Không | Không | Không |
| Làm sao biết nó **đang khỏe**? | Gọi `/healthz` | Gọi `/api/health` (có thử cả DB) | Lệnh `pg_isready` |

### 1.3 Vẽ sơ đồ ai nói chuyện với ai
```
 Người dùng ──► web ──► api ──► db
```
Mũi tên chỉ có **một chiều đi vào trong**. Từ đó rút ra luật quan trọng:
- Chỉ `web` được mở cổng ra ngoài.
- `db` **không bao giờ** được mở ra ngoài (trừ lúc phát triển, và chỉ cho máy bạn).
- `web` **không** cần thấy `db`. Nên ta chia mạng thành **khu ngoài** (web, api) và **khu trong** (api, db).

### 1.4 Ghi lại thành bảng quyết định
Đây là sản phẩm của bước 1. Mọi quyết định trong `compose.yaml` đều bắt nguồn từ bảng này:

| Quyết định | Lý do | Nơi thể hiện trong dự án |
|---|---|---|
| 3 container riêng cho 3 phần | Cập nhật, mở rộng từng phần độc lập | 3 dịch vụ trong `compose.yaml` |
| Dữ liệu DB nằm trong volume `du-lieu-db` | Xóa container không mất dữ liệu | `volumes:` trong `compose.yaml` |
| Mật khẩu DB để trong file, không ghi vào cấu hình | Tránh lộ mật khẩu | `secrets:` + `bi-mat/` |
| Chỉ `web` có `ports:` | Giảm bề mặt bị tấn công | `compose.yaml` |
| Hai khu mạng | `web` không với tới `db` | `networks:` |
| Mỗi phần có healthcheck | Khởi động đúng thứ tự, tự phát hiện hỏng | `healthcheck` / `depends_on` |
| Có giới hạn CPU và bộ nhớ | Một phần hỏng không ăn hết máy | `deploy.resources.limits` |

## Kiểm tra (bạn đã xong bước 1 khi…)
- [ ] Bạn nói được ứng dụng gồm mấy phần, mỗi phần chạy bằng gì, nghe cổng nào.
- [ ] Bạn chỉ ra được phần nào cần volume, phần nào cần mật khẩu.
- [ ] Bạn vẽ được sơ đồ mũi tên và chỉ ra "cửa" duy nhất mở ra ngoài.

## Bài tập: áp dụng cho web của chính bạn
Lấy một web bạn từng làm (hoặc sắp làm) và điền bảng 1.1 và 1.2 cho nó. Nếu có thêm phần như Redis (bộ nhớ đệm), hàng đợi công việc, hay kho lưu ảnh, hãy thêm một cột cho chúng. Chưa điền được thì chưa nên viết Dockerfile.

Tiếp theo: [Bước 2: Viết Dockerfile](02-viet-dockerfile.md)
