# Bài 2: Cài đặt và cấu hình

## Làm gì trong bài này
Cài Git, nói cho Git biết bạn là ai, và chuẩn bị đăng nhập GitHub. Chỉ làm **một lần** trên mỗi máy.

## 2.1 Cài Git

| Hệ điều hành | Cách cài |
|---|---|
| **Windows** | Tải **Git for Windows** tại git-scm.com, cài với các lựa chọn mặc định. Nó kèm **Git Bash** (cửa sổ dòng lệnh) và **Git Credential Manager** (giúp đăng nhập GitHub) |
| **macOS** | Gõ `git --version` trong Terminal, máy sẽ gợi ý cài; hoặc `brew install git` |
| **Ubuntu/Debian** | `sudo apt-get install -y git` |

Kiểm tra:
```sh
git --version
```
Hiện ra số phiên bản (ví dụ `git version 2.4x.x`) là xong. Các lệnh `git switch` và `git restore` trong bộ bài này cần Git từ bản 2.23 trở lên (ra mắt từ 2019, máy nào cài mới đều có).

## 2.2 Khai báo bạn là ai
Mỗi commit đều ghi tên và email người lưu. Khai báo một lần:
```sh
git config --global user.name "Ten Cua Ban"
git config --global user.email "email-cua-ban@example.com"
```
Dùng đúng email đã đăng ký GitHub để commit hiện đúng tên bạn trên đó. Muốn giữ kín email thật, GitHub cho bạn một địa chỉ riêng dạng `ma-so+ten@users.noreply.github.com` (Settings → Emails).

Kiểm tra lại:
```sh
git config --global --list
```

## 2.3 Vài cấu hình nên đặt luôn
```sh
git config --global init.defaultBranch main     # nhánh chính mặc định của repo MỚI tên là main
git config --global pull.rebase false           # khi pull thì gộp (merge) kiểu đơn giản, dễ hiểu nhất
git config --global core.autocrlf true          # CHỈ trên Windows: xem giải thích dưới
git config --global core.editor "code --wait"   # (tùy chọn) dùng VS Code để viết ghi chú commit dài
```

### Vì sao có dòng `autocrlf` (chỉ Windows)?
Windows kết thúc dòng bằng hai ký tự `CRLF`, Linux/macOS dùng một ký tự `LF`. Nếu hai bên lẫn lộn, Git thấy "cả file thay đổi" dù bạn chỉ sửa một chữ, và script `.sh` có thể không chạy trên Linux.
- `core.autocrlf true` trên Windows: Git tự đổi cho khớp khi lưu và lấy ra.
- Bạn sẽ thấy cảnh báo kiểu `LF will be replaced by CRLF` khi `git add`. **Đây chỉ là thông báo, không phải lỗi.**
- Repo này có file `.gitattributes` ép các file `.sh`, `.conf`, `Dockerfile` luôn dùng `LF` để chạy đúng trên Linux và trong container.

## 2.4 Đăng nhập GitHub

GitHub **không còn chấp nhận mật khẩu tài khoản** khi dùng Git qua dòng lệnh. Có hai cách thông dụng:

### Cách A (dễ nhất): HTTPS + trình quản lý đăng nhập
1. Lấy địa chỉ clone dạng `https://github.com/ten-ban/ten-repo.git`.
2. Lần đầu `git push` hoặc `git clone` repo riêng tư, một cửa sổ trình duyệt hiện ra để bạn đăng nhập GitHub. Git Credential Manager (đi kèm Git for Windows và macOS) nhớ lại cho những lần sau.
3. Nếu máy không có trình duyệt (máy chủ), dùng **Personal Access Token**: GitHub → Settings → Developer settings → Personal access tokens, tạo token có quyền `repo`, rồi dán token vào ô "password" khi Git hỏi. Token là bí mật, đối xử như mật khẩu.

### Cách B: SSH (làm một lần, về sau không bị hỏi)
```sh
ssh-keygen -t ed25519 -C "email-cua-ban@example.com"     # cứ Enter hết các câu hỏi
cat ~/.ssh/id_ed25519.pub                                # in khóa CÔNG KHAI; sao chép toàn bộ
```
Dán vào GitHub → Settings → SSH and GPG keys → New SSH key. Thử: `ssh -T git@github.com`. Khi đó dùng địa chỉ dạng `git@github.com:ten-ban/ten-repo.git`.

> **Tuyệt đối không** gửi hoặc đưa lên git file khóa **riêng** (`id_ed25519`, không có đuôi `.pub`).

## Tự kiểm tra
1. Vì sao phải khai báo `user.name` và `user.email`?
2. Cảnh báo `LF will be replaced by CRLF` là lỗi hay thông báo?
3. Khi GitHub từ chối mật khẩu, bạn dùng gì thay thế?

Tiếp theo: [Bài 3: Commit cơ bản](03-commit-co-ban.md)
