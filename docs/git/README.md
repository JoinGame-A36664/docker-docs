# Học Git đủ dùng để quản lý tài liệu

Git là công cụ giúp bạn **lưu lại từng phiên bản** của tài liệu, **thử nghiệm mà không sợ hỏng bản đang tốt**, và **đưa lên GitHub** để lưu trữ và chia sẻ. Bạn đang dùng chính Git để quản lý repo này.

Bộ bài này chỉ dạy **phần cần thiết hằng ngày**. Không có kỹ thuật nâng cao (rebase, cherry-pick, submodule...). Học xong bạn sẽ tự tin làm được: sửa tài liệu → lưu phiên bản → làm trên nhánh riêng → đưa lên GitHub → gộp vào nhánh chính → quay lại khi lỡ sai.

## Git trong một phút

```
 Bạn sửa file ──► git add ──► git commit ──► git push
 (thư mục làm việc)  (chọn thứ cần lưu)  (lưu thành 1 phiên bản)  (đưa lên GitHub)
```
- **Commit** = một "điểm lưu" có tên và ghi chú, giống save game. Muốn quay lại điểm nào cũng được.
- **Nhánh (branch)** = một "đường làm việc riêng". Bạn thử ý tưởng trên nhánh riêng, ưng thì mới gộp vào nhánh chính.
- **GitHub** = nơi lưu bản sao repo trên mạng. Máy hỏng thì code vẫn còn.

## Lộ trình học

| Bài | Nội dung | Thời gian |
|---|---|---|
| [01. Git là gì?](01-git-la-gi.md) | Ba "vùng" của Git, repo, commit, nhánh, remote | 10 phút đọc |
| [02. Cài đặt và cấu hình](02-cai-dat-va-cau-hinh.md) | Cài Git, khai báo tên và email, đăng nhập GitHub | 15 phút |
| [03. Commit cơ bản](03-commit-co-ban.md) | `status`, `add`, `commit`, `diff`, `log`, `.gitignore` | 30 phút |
| [04. Nhánh](04-nhanh.md) | Tạo nhánh, chuyển nhánh, gộp nhánh, xử lý xung đột | 30 phút |
| [05. GitHub: đẩy và kéo code](05-github-day-va-keo-code.md) | `clone`, `push`, `pull`, Pull Request | 30 phút |
| [06. Hoàn tác an toàn](06-hoan-tac-an-toan.md) | Lỡ sai thì quay lại thế nào | 20 phút |
| [07. Quy trình cho repo tài liệu](07-quy-trinh-lam-viec-voi-repo-tai-lieu.md) | Quy trình hằng ngày, đặt tên nhánh/commit, đánh số phiên bản bằng tag | 15 phút |
| [Bảng tóm tắt lệnh](bang-tom-tat-lenh.md) | Tra nhanh | |
| [Bài tập thực hành](bai-tap-thuc-hanh.md) | Làm trên một thư mục thử, không đụng tới repo thật | 45 phút |

**Cách học tốt nhất:** đọc bài 01 và 02, rồi làm song song bài 03 đến 06 với [bài tập thực hành](bai-tap-thuc-hanh.md).

## Một quy tắc vàng
> **Commit sớm, commit thường xuyên, mỗi commit một việc.** Điểm lưu càng nhỏ và có tên rõ thì càng dễ quay lại và càng dễ hiểu lịch sử.
