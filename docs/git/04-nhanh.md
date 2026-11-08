# Bài 4: Nhánh (branch)

## Làm gì trong bài này
Học tạo một "đường làm việc riêng" để thử nghiệm an toàn, rồi gộp kết quả tốt vào nhánh chính.

## 4.1 Nhánh là gì? Hình dung bằng tài liệu

Bạn có bản tài liệu đang tốt ở nhánh `main`. Bạn muốn viết lại cả chương Docker Compose nhưng chưa chắc ưng. Thay vì sửa thẳng vào bản đang tốt:

```
main:      A ──── B ──── C
                         \
cap-nhat-compose:         D ──── E        ← bạn thử nghiệm ở đây
```
- `main` vẫn nguyên vẹn (A, B, C).
- Mọi thay đổi thử nghiệm nằm ở D, E trên nhánh riêng.
- Ưng thì **gộp (merge)** vào `main`; không ưng thì bỏ nhánh, `main` không bị ảnh hưởng gì.

Tạo nhánh rất rẻ và nhanh trong Git, nên cứ **mỗi việc một nhánh**.

## 4.2 Các lệnh với nhánh

```sh
git branch                          # xem các nhánh trên máy; dấu * là nhánh bạn đang đứng
git branch --show-current           # chỉ in tên nhánh hiện tại
git switch -c ten-nhanh-moi         # TẠO nhánh mới và CHUYỂN sang đó
git switch main                     # chuyển về nhánh main
git switch ten-nhanh                # chuyển sang nhánh có sẵn
git branch -a                       # xem cả nhánh trên remote (GitHub)
git branch -d ten-nhanh             # xóa nhánh ĐÃ gộp (an toàn)
git branch -D ten-nhanh             # xóa nhánh dù CHƯA gộp (mất công việc trên nhánh đó!)
```
(`git checkout` làm được tương tự, là lệnh cũ. Bài này dùng `git switch` cho dễ nhớ.)

### Đặt tên nhánh
Ngắn, thường viết thường, nối bằng dấu gạch ngang, có tiền tố cho biết loại việc:

| Tiền tố | Dùng cho | Ví dụ |
|---|---|---|
| `docs/` | Viết hoặc sửa tài liệu | `docs/update-docker-2026` |
| `fix/` | Sửa lỗi | `fix/link-hong-network` |
| `feat/` | Thêm tính năng/nội dung lớn mới | `feat/bai-git` |
| `chore/` | Việc dọn dẹp | `chore/sap-xep-thu-muc` |

## 4.3 Chuyển nhánh khi đang có thay đổi chưa lưu
Git sẽ từ chối chuyển nếu việc chuyển làm mất thay đổi của bạn. Có 2 cách xử lý:
1. **Commit** thay đổi trước, rồi chuyển (khuyên dùng).
2. **Cất tạm** bằng `git stash`:
   ```sh
   git stash                  # cất các thay đổi vào ngăn tạm; thư mục sạch trở lại
   git switch main
   # ... làm việc khác ...
   git switch nhanh-cu
   git stash pop              # lấy thay đổi đã cất ra lại
   ```

## 4.4 Gộp nhánh (merge)

Giả sử xong việc ở `docs/them-bai-git`, muốn đưa vào `main`:

```sh
git switch main                     # 1. về nhánh NHẬN thay đổi
git pull                            # 2. cập nhật main mới nhất (nếu có GitHub)
git merge docs/them-bai-git         # 3. gộp nhánh kia vào main
git branch -d docs/them-bai-git     # 4. xóa nhánh đã gộp xong
```
Có hai kết quả:
- **Fast-forward**: `main` chưa có gì mới từ lúc bạn tách nhánh, Git chỉ "kéo" `main` tới đầu nhánh của bạn. Không có commit gộp.
- **Merge commit**: cả hai nhánh đều có commit mới, Git tạo thêm một commit gộp.

Trên GitHub, bạn thường gộp bằng **Pull Request** (bài 5) thay vì gõ `git merge` thủ công.

## 4.5 Xung đột (conflict) và cách xử lý bình tĩnh
Xung đột xảy ra khi **cùng một chỗ trong cùng một file** bị hai nhánh sửa khác nhau. Git không tự quyết được nên nhờ bạn chọn. Đừng hoảng, đây là chuyện bình thường.

Khi `git merge` báo `CONFLICT`, Git đánh dấu trong file:
```
<<<<<<< HEAD
Dòng này từ nhánh bạn đang đứng (main).
=======
Dòng này từ nhánh đang gộp vào.
>>>>>>> docs/them-bai-git
```
Các bước:
1. `git status` để thấy file nào đang xung đột (mục `both modified`).
2. Mở file, **tự quyết** giữ phần nào (hoặc viết lại kết hợp cả hai), rồi **xóa 3 dòng đánh dấu** `<<<<<<<`, `=======`, `>>>>>>>`.
3. Lưu file, rồi:
   ```sh
   git add ten-file-da-sua.md
   git commit                     # Git đã soạn sẵn ghi chú "Merge branch ..."; cứ lưu lại
   ```
4. Muốn bỏ cuộc và quay về trước khi gộp: `git merge --abort`.

VS Code hiển thị xung đột với các nút "Accept Current / Incoming / Both" rất tiện.

**Cách giảm xung đột:** nhánh sống ngắn, thường xuyên cập nhật từ `main`, và đừng ai sửa cùng một đoạn cùng lúc.

## 4.6 Xem sự khác nhau giữa hai nhánh
```sh
git diff main..docs/update-docker-2026 --stat      # tóm tắt file nào khác
git log main..docs/update-docker-2026 --oneline    # các commit có ở nhánh kia mà main chưa có
```

## Tóm tắt quy trình một nhánh
```sh
git switch main && git pull               # bắt đầu từ main mới nhất
git switch -c docs/ten-viec               # tạo nhánh cho việc mới
# ... sửa, git add, git commit (nhiều lần) ...
git switch main && git merge docs/ten-viec
git branch -d docs/ten-viec
```

## Tự kiểm tra
1. Tạo nhánh có làm thay đổi `main` không?
2. `git branch -d` và `git branch -D` khác nhau thế nào? Khi nào dùng cái sau?
3. Khi gặp `CONFLICT`, bạn phải làm những việc gì?
4. Đang sửa dở mà cần chuyển nhánh gấp, có hai cách nào?

Tiếp theo: [Bài 5: GitHub, đẩy và kéo code](05-github-day-va-keo-code.md)
