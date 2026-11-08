# Bài 3: Commit cơ bản

## Làm gì trong bài này
Làm quen vòng lặp quan trọng nhất: **sửa → xem → chọn → lưu**. Bạn sẽ dùng nó mỗi ngày.

## 3.1 Bắt đầu một repo

**Có sẵn repo trên GitHub** (trường hợp phổ biến nhất): tải về
```sh
git clone https://github.com/ten-ban/ten-repo.git
cd ten-repo
```

**Thư mục chưa phải repo**: biến nó thành repo
```sh
cd thu-muc-cua-ban
git init
```
Lệnh `init` tạo thư mục ẩn `.git`. Có `.git` là repo; xóa `.git` là mất toàn bộ lịch sử.

## 3.2 Vòng lặp hằng ngày

```
   sửa file ──► git status ──► git diff ──► git add ──► git commit
```

### Bước 1. Xem tình hình: `git status`
```sh
git status
```
Lệnh này cho biết: đang ở nhánh nào, file nào **đã sửa**, file nào **mới (chưa theo dõi)**, file nào **đã chọn (staged)**. Khi không biết làm gì tiếp, **gõ `git status`**. Dạng ngắn gọn hơn:
```sh
git status -sb
```
Ký hiệu cột trái: `M` đã sửa, `A` mới thêm, `D` đã xóa, `R` đổi tên, `??` file mới chưa theo dõi.

### Bước 2. Xem chính xác đã sửa gì: `git diff`
```sh
git diff                 # thay đổi CHƯA chọn (chưa add)
git diff --staged        # thay đổi ĐÃ chọn (chuẩn bị commit)
git diff ten-file.md     # chỉ một file
```
Dòng bắt đầu bằng `+` là thêm, `-` là xóa. Hãy tập thói quen xem `diff` trước khi commit để chắc mình chỉ lưu đúng thứ định lưu.

### Bước 3. Chọn thứ cần lưu: `git add`
```sh
git add README.md                # một file
git add docs/git/                # cả một thư mục
git add -A                       # tất cả thay đổi (cẩn thận: đọc git status trước!)
```
Nếu một file có nhiều chỗ sửa mà chỉ muốn lưu một phần, dùng `git add -p` (Git hỏi từng đoạn). Đây là kỹ thuật hay nhưng không bắt buộc.

### Bước 4. Lưu thành một điểm: `git commit`
```sh
git commit -m "Them bai Git co ban"
```
Không có `-m` thì Git mở trình soạn thảo để bạn gõ ghi chú.

### Bước 5. Xem lịch sử: `git log`
```sh
git log --oneline            # mỗi commit một dòng
git log --oneline -10        # 10 commit gần nhất
git log --oneline --graph --all   # có vẽ nhánh
git log -p ten-file.md       # lịch sử thay đổi của một file
git show a6da88b             # chi tiết một commit (thay bằng mã của bạn)
```
Bấm `q` để thoát màn hình xem.

## 3.3 Viết ghi chú commit tốt
Ghi chú là thứ bạn (và người khác) đọc sau này để hiểu "vì sao".

| Tốt | Chưa tốt |
|---|---|
| `Sua loi link trong bai Network` | `update` |
| `Them bai Git: nhanh va gop nhanh` | `sua linh tinh` |
| `Cap nhat huong dan cai Docker cho Ubuntu 24.04` | `final final 2` |

Gợi ý:
- Viết ngắn, nêu **việc đã làm** (ví dụ "Thêm...", "Sửa...", "Cập nhật...", "Xóa...").
- Dòng đầu không quá khoảng 70 ký tự. Muốn giải thích thêm thì để dòng trống rồi viết tiếp bên dưới.
- Mỗi commit **một việc**. Sửa lỗi chính tả và thêm một bài mới là hai commit.
- Dùng tiếng Việt có dấu hay không dấu đều được; quan trọng là **cả nhóm thống nhất**. Với terminal Windows cũ, không dấu tránh lỗi hiển thị.

## 3.4 `.gitignore`: những thứ KHÔNG đưa vào Git
Tạo file tên `.gitignore` ở gốc repo, mỗi dòng một mẫu:
```
.env
*.log
node_modules/
__pycache__/
bi-mat/db_password.txt
```
- File khớp mẫu sẽ không hiện trong `git status` và không bị `add`.
- Nên ignore: mật khẩu và khóa (`.env`, `*.key`), file sinh ra tự động (`node_modules/`, `__pycache__/`, file build), file tạm của trình soạn thảo.
- `.gitignore` chỉ ngăn file **chưa theo dõi**. Nếu file đã bị commit rồi thì phải gỡ khỏi Git: `git rm --cached ten-file` (file vẫn còn trên máy), rồi commit.
- Kiểm tra một file có bị bỏ qua không và bởi dòng nào: `git check-ignore -v bi-mat/db_password.txt`.

> **Cảnh báo quan trọng:** nếu bạn đã lỡ commit một mật khẩu hay khóa và đẩy lên GitHub, **xóa file đi là chưa đủ**, vì lịch sử vẫn còn. Hãy **đổi mật khẩu/khóa ngay**, coi như đã lộ.

## 3.5 Đổi tên và xóa file
Đổi tên hoặc di chuyển file **bằng Git** để lịch sử nhận ra đó là cùng một file:
```sh
git mv ten-cu.md ten-moi.md
git mv bai-a.md thu-muc/bai-a.md
git rm bai-khong-can.md
```
(Bạn cũng có thể đổi tên bằng chuột rồi `git add -A`; Git thường tự nhận ra, nhưng `git mv` chắc chắn hơn. Repo này vừa dùng `git mv` để xếp lại thư mục `docker-coban`.)

## Tóm tắt vòng lặp
```sh
git status -sb
git diff
git add <file-hoac-thu-muc>
git commit -m "Mo ta ngan gon viec da lam"
git log --oneline -5
```

## Tự kiểm tra
1. `git add` và `git commit` khác nhau thế nào?
2. Làm sao biết file nào đã sửa mà chưa `add`?
3. Vì sao không nên dùng ghi chú "update"?
4. Bạn lỡ tạo file `.env` chứa mật khẩu. Làm sao để Git không bao giờ đưa nó vào?

Tiếp theo: [Bài 4: Nhánh](04-nhanh.md)
