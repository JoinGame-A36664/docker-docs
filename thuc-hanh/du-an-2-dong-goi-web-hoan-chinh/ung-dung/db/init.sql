-- File này được PostgreSQL chạy MỘT LẦN DUY NHẤT, vào lần đầu cơ sở dữ liệu được tạo (khi ổ dữ liệu còn trống).
-- Những lần khởi động sau, nó KHÔNG chạy lại. Muốn đổi cấu trúc bảng khi hệ thống đã chạy,
-- cần viết một bước "nâng cấp" riêng (xem kế hoạch, mục vận hành).

CREATE TABLE IF NOT EXISTS tasks (
    id         SERIAL      PRIMARY KEY,                 -- số thứ tự tự tăng
    title      TEXT        NOT NULL,                    -- nội dung công việc
    done       BOOLEAN     NOT NULL DEFAULT FALSE,      -- đã xong chưa
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()       -- thời điểm tạo
);

-- Thêm vài việc mẫu để lần đầu mở trang không bị trống.
INSERT INTO tasks (title, done) VALUES
    ('Đọc kế hoạch đóng gói trong thư mục ke-hoach', FALSE),
    ('Chạy thử cả hệ thống bằng một lệnh docker compose', FALSE),
    ('Thử sao lưu cơ sở dữ liệu', FALSE);
