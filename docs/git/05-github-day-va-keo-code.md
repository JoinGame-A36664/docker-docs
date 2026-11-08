# Bài 5: GitHub, đẩy và kéo code

## Làm gì trong bài này
Đưa repo lên GitHub, đồng bộ giữa máy bạn và GitHub, và gộp nhánh bằng Pull Request.

## 5.1 Remote: "địa chỉ" của bản sao trên mạng
Remote là địa chỉ của repo trên GitHub. Tên thường dùng là `origin`.
```sh
git remote -v                       # xem các remote đang có
git remote add origin https://github.com/ten-ban/ten-repo.git     # thêm (chỉ khi repo tạo bằng git init)
```
Nếu bạn `git clone` thì `origin` đã có sẵn.

## 5.2 Đẩy repo lên GitHub lần đầu
Trường hợp bạn đã có repo trên máy và muốn đưa lên:
1. Trên GitHub bấm **New repository**, đặt tên, **không** tick tạo sẵn README (để repo trống).
2. Trong thư mục repo trên máy:
   ```sh
   git remote add origin https://github.com/ten-ban/ten-repo.git
   git branch -M main
   git push -u origin main
   ```
   `-u` gắn nhánh `main` trên máy với `origin/main` trên GitHub; về sau chỉ cần gõ `git push` và `git pull`.

## 5.3 Đẩy một nhánh mới lên GitHub
```sh
git switch -c docs/them-bai-git
# ... sửa, add, commit ...
git push -u origin docs/them-bai-git
```
Lần đầu đẩy nhánh mới cần `-u origin ten-nhanh`. Từ lần sau trên nhánh đó chỉ cần `git push`.

## 5.4 Ba lệnh đồng bộ: `fetch`, `pull`, `push`

| Lệnh | Làm gì | Có đổi file của bạn không? |
|---|---|---|
| `git fetch` | Tải thông tin mới từ GitHub về, **chưa** đụng vào file của bạn | Không |
| `git pull` | = `fetch` + gộp (merge) vào nhánh hiện tại | Có |
| `git push` | Đẩy commit của bạn lên GitHub | Không đổi file ở máy |

```sh
git pull        # lấy cập nhật mới nhất về nhánh hiện tại
git push        # đưa commit của bạn lên
```
**Thói quen tốt:** `git pull` **trước khi** bắt đầu làm việc, `git push` **sau khi** commit xong.

Nếu `git push` báo bị từ chối vì GitHub có commit mới mà máy bạn chưa có (`rejected ... fetch first`): chạy `git pull` (xử lý xung đột nếu có) rồi `git push` lại. **Đừng** dùng `git push --force` khi chưa hiểu rõ, vì nó có thể xóa công việc của người khác.

## 5.5 Lấy một nhánh có sẵn trên GitHub về máy
```sh
git fetch origin
git switch docs/update-docker-2026       # Git tự tạo nhánh cục bộ theo dõi origin/docs/update-docker-2026
git pull                                 # lấy các commit mới của nhánh đó
```

## 5.6 Pull Request (PR): cách gộp có xem xét
PR là lời đề nghị gộp nhánh của bạn vào nhánh chính, kèm chỗ để mô tả, xem thay đổi, và bình luận.

Quy trình trên GitHub:
1. Đẩy nhánh lên (`git push -u origin ten-nhanh`).
2. Vào repo trên GitHub, bấm nút **Compare & pull request** (hoặc tab *Pull requests* → *New*).
3. Chọn: **base** = nhánh nhận (thường `main`), **compare** = nhánh của bạn.
4. Viết tiêu đề và mô tả ngắn: đã đổi gì, vì sao.
5. Xem tab **Files changed** để tự kiểm tra lần cuối, rồi bấm **Create pull request**.
6. Người khác (hoặc chính bạn nếu làm một mình) xem xét, rồi bấm **Merge pull request**.
7. Về máy:
   ```sh
   git switch main
   git pull
   git branch -d docs/them-bai-git        # dọn nhánh đã gộp
   ```

GitHub có 3 kiểu gộp:
| Kiểu | Kết quả | Khi nào dùng |
|---|---|---|
| Create a merge commit | Giữ đủ mọi commit + thêm 1 commit gộp | Mặc định, an toàn |
| Squash and merge | Dồn cả nhánh thành **một** commit trên main | Nhánh có nhiều commit lặt vặt, muốn lịch sử `main` gọn |
| Rebase and merge | Xếp lại từng commit lên main | Nâng cao, tạm thời chưa cần |

Làm một mình vẫn nên dùng PR: nó cho bạn một chỗ **xem lại toàn bộ thay đổi** trước khi vào `main`, và để lại lịch sử rõ ràng.

## 5.7 Bảo vệ nhánh `main` (nên bật)
Trên GitHub: Settings → Branches → Add rule cho `main`: bắt buộc qua Pull Request mới được gộp. Nhờ vậy không ai (kể cả bạn lúc vội) lỡ đẩy thẳng vào `main`.

## Tóm tắt
```sh
git pull                                   # bắt đầu ngày
git switch -c docs/ten-viec                # nhánh mới
# ... sửa, add, commit ...
git push -u origin docs/ten-viec           # đẩy nhánh
# -> trên GitHub: tạo Pull Request, xem lại, Merge
git switch main && git pull                # kéo bản đã gộp về
git branch -d docs/ten-viec                # dọn
```

## Tự kiểm tra
1. `git fetch` khác `git pull` thế nào?
2. Vì sao lần đầu đẩy nhánh mới cần `-u`?
3. `git push` bị từ chối vì "fetch first", bạn làm gì?
4. Pull Request giúp ích gì ngay cả khi bạn làm một mình?

Tiếp theo: [Bài 6: Hoàn tác an toàn](06-hoan-tac-an-toan.md)
