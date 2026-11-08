# Danh sách kiểm tra đóng gói một web

Dùng cho **bất kỳ web nào**. In ra hoặc chép vào ghi chú, tick từng dòng. Chỗ nào chưa tick được là việc cần làm tiếp.

## Bước 1. Phân tích
- [ ] Liệt kê đủ các phần của ứng dụng (giao diện, xử lý, cơ sở dữ liệu, bộ nhớ đệm, hàng đợi...).
- [ ] Mỗi phần: cổng nghe, có cần lưu dữ liệu không, có cần mật khẩu không.
- [ ] Vẽ sơ đồ ai gọi ai; chỉ ra cửa duy nhất mở ra ngoài.
- [ ] Có bảng quyết định (cái gì làm sao, vì sao).

## Bước 2. Dockerfile
- [ ] Mỗi phần một image; image gốc có **phiên bản cụ thể** (không dùng `latest`).
- [ ] Chép file khai báo thư viện trước, chép code sau.
- [ ] Dùng nhiều giai đoạn (multi-stage) khi có bước cài/biên dịch.
- [ ] Chạy bằng tài khoản thường (`USER`).
- [ ] Có `HEALTHCHECK`.
- [ ] Lệnh khởi động viết dạng danh sách `["...", "..."]`.
- [ ] Có `.dockerignore` (loại `.git`, `.env`, file tạm).
- [ ] Không có mật khẩu nào bên trong image (`docker history` không thấy).

## Bước 3. Phát triển
- [ ] Có file chồng `compose.dev.yaml` (sửa code thấy ngay).
- [ ] Dùng cùng loại cơ sở dữ liệu / dịch vụ như khi chạy thật.
- [ ] Cổng cơ sở dữ liệu chỉ mở cho `127.0.0.1` khi phát triển.

## Bước 4. Chạy thật
- [ ] Chỉ một dịch vụ có `ports:`.
- [ ] Chia khu mạng (ngoài / trong).
- [ ] `healthcheck` + `depends_on: condition: service_healthy` đúng thứ tự.
- [ ] `restart: unless-stopped`.
- [ ] Giới hạn CPU, bộ nhớ (`deploy.resources.limits`).
- [ ] Giới hạn dung lượng nhật ký (`logging.options`).
- [ ] Dữ liệu cần giữ nằm trong **volume**.
- [ ] Phần xử lý: `read_only`, `cap_drop: ALL`, `no-new-privileges` (nếu chạy được).
- [ ] Tên image có **số phiên bản**.

## Bước 5. Bí mật và cấu hình
- [ ] Mật khẩu nằm trong file `secrets`, không nằm trong `compose.yaml`, `.env`, Dockerfile.
- [ ] `.env` và file mật khẩu nằm trong `.gitignore`; có `.env.example` làm mẫu.
- [ ] Mật khẩu môi trường chạy thật khác với môi trường phát triển.
- [ ] Biết cách **đổi mật khẩu** (không chỉ sửa file).

## Bước 6. Sao lưu
- [ ] Có lệnh sao lưu chạy được.
- [ ] Đã **thử khôi phục thành công** ít nhất một lần.
- [ ] Có lịch sao lưu tự động.
- [ ] Bản sao lưu được chép ra **nơi khác** máy chủ.
- [ ] Có kế hoạch dọn bản cũ.

## Bước 7. Tự động hóa (CI)
- [ ] Mỗi lần đẩy code: tự dựng hệ thống và gọi thử.
- [ ] Tự đóng gói image, gắn nhãn phiên bản.
- [ ] Bí mật thật nằm trong Settings → Secrets, không nằm trong repo.
- [ ] (Nên có) Quét lỗ hổng image.

## Bước 8. Triển khai
- [ ] Docker + Compose đã cài trên máy chủ; Docker tự bật khi máy khởi động.
- [ ] Tường lửa chỉ mở SSH, 80, 443.
- [ ] Cổng cơ sở dữ liệu **không** truy cập được từ ngoài.
- [ ] Cả hệ thống `healthy` và truy cập được từ máy khác.
- [ ] Khởi động lại máy chủ: hệ thống tự trở lại.
- [ ] Có tên miền và HTTPS (khi mở cho người dùng thật).

## Bước 9. Vận hành
- [ ] Có quy trình cập nhật (sao lưu → đổi số phiên bản → thay thế → kiểm tra).
- [ ] Có cách quay lại bản cũ, đã thử một lần.
- [ ] Có cách đổi cấu trúc bảng an toàn (file nâng cấp đánh số, sao lưu trước).
- [ ] Biết xem nhật ký, `docker stats`, `docker system df`.
- [ ] Có lịch việc định kỳ (hàng tuần, hàng tháng, hàng quý).
