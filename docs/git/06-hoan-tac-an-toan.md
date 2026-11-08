# Bài 6: Hoàn tác an toàn

## Làm gì trong bài này
Biết cách quay lại khi lỡ sai. Đây là lý do chính để dùng Git: **hầu như mọi sai lầm đều sửa được**, miễn là bạn đã commit.

## Nguyên tắc để nhớ
1. **Việc đã commit gần như không bao giờ mất.** Việc chưa commit thì có thể mất, nên commit sớm.
2. Chưa `push` thì sửa lịch sử thoải mái (vì chỉ mình bạn thấy). **Đã `push` rồi thì đừng sửa lịch sử, hãy tạo commit mới để đảo ngược** (`git revert`).
3. Trước khi gõ lệnh có chữ `--hard`, dừng lại đọc kỹ: chúng có thể xóa vĩnh viễn thay đổi chưa commit.

## Bảng chọn nhanh: bạn đang ở tình huống nào?

| Tình huống | Lệnh |
|---|---|
| Sửa file rồi, **chưa add**, muốn bỏ thay đổi, trả file về như lần commit gần nhất | `git restore ten-file` |
| **Đã add** rồi nhưng không muốn đưa vào commit này | `git restore --staged ten-file` |
| Vừa commit xong, **chưa push**, muốn sửa ghi chú | `git commit --amend -m "Ghi chu moi"` |
| Vừa commit xong, **chưa push**, quên một file | `git add file-quen` rồi `git commit --amend --no-edit` |
| Vừa commit xong, **chưa push**, muốn hủy commit nhưng **giữ lại** thay đổi để sửa tiếp | `git reset --soft HEAD~1` |
| Commit **đã push**, muốn hủy tác dụng của nó | `git revert <ma-commit>` |
| Muốn xem dự án ở một thời điểm cũ | `git switch --detach <ma-commit>` (về lại: `git switch main`) |
| Muốn lấy lại **một file** từ commit cũ | `git restore --source=<ma-commit> ten-file` |
| Lỡ xóa nhầm file chưa commit | Không có cách của Git (chưa được lưu); xem thùng rác của hệ điều hành |
| Lỡ xóa nhầm file **đã commit** | `git restore ten-file` |
| Lỡ xóa nhầm một nhánh | `git reflog` để tìm mã commit, rồi `git switch -c ten-nhanh <ma>` |

## Ví dụ từng tình huống

### A. Sửa nhầm file, muốn bỏ hết thay đổi của file đó
```sh
git status -sb                  # thấy " M README.md"
git restore README.md           # trả README.md về bản đã commit
```
⚠ Thay đổi chưa commit của file đó **biến mất**, không lấy lại được.

### B. Lỡ `git add` nhầm file
```sh
git restore --staged file-nham.md        # bỏ khỏi khu chuẩn bị; file vẫn giữ nguyên thay đổi
```

### C. Viết sai ghi chú commit (chưa push)
```sh
git commit --amend -m "Sua loi link trong bai Network"
```

### D. Hủy commit cuối nhưng giữ công việc (chưa push)
```sh
git reset --soft HEAD~1
git status -sb                           # các thay đổi đang ở trạng thái "đã add"; sửa tiếp rồi commit lại
```
`HEAD~1` nghĩa là "lùi 1 commit".

### E. Commit đã đẩy lên GitHub mà có lỗi: dùng `revert`
```sh
git log --oneline -5                     # tìm mã của commit cần hủy, ví dụ 3f9a1c2
git revert 3f9a1c2                       # tạo commit MỚI làm ngược lại commit đó
git push
```
`revert` không viết lại lịch sử nên an toàn kể cả khi người khác đã kéo code của bạn.

### F. Xem lại dự án ở một thời điểm cũ rồi quay về
```sh
git log --oneline                        # chọn mã commit muốn xem
git switch --detach 3f9a1c2              # đứng tại commit đó (chế độ "xem"; Git sẽ nhắc bạn đang ở detached HEAD)
# ... xem file, chạy thử ...
git switch main                          # quay về như cũ
```
Đứng ở chế độ này đừng commit thêm (sẽ khó tìm lại); chỉ để xem. Muốn làm tiếp từ đó thì tạo nhánh: `git switch -c nhanh-thu-lai`.

### G. Lỡ làm hỏng nặng? Tìm lại bằng `reflog`
`git reflog` ghi mọi nơi mà HEAD từng đi qua (ngay cả khi bạn xóa nhánh hay `reset`). Đây là "lưới an toàn" cuối cùng:
```sh
git reflog                               # tìm dòng ứng với thời điểm còn tốt, nhớ mã ở cột trái
git switch -c cuu-ho <ma>                # tạo nhánh tại đúng thời điểm đó
```
(Thông tin reflog giữ trong một thời gian, thường là vài tuần, và chỉ có trên máy bạn.)

## Những lệnh nguy hiểm: cần nhớ để TRÁNH
| Lệnh | Vì sao nguy hiểm |
|---|---|
| `git reset --hard` | Xóa mọi thay đổi chưa commit, đưa nhánh về một commit khác |
| `git restore .` | Bỏ hết thay đổi chưa commit của mọi file |
| `git clean -fd` | Xóa file/thư mục chưa theo dõi |
| `git push --force` | Ghi đè lịch sử trên GitHub, có thể làm mất công việc của người khác |
| `git branch -D` | Xóa nhánh dù chưa gộp |

Cách giữ an toàn: trước khi chạy lệnh nguy hiểm, **commit hoặc `git stash` trước** để có chỗ quay lại. `git status` và `git diff` luôn là bạn.

## Tự kiểm tra
1. Khác biệt giữa `git restore file` và `git restore --staged file`?
2. Commit đã push có lỗi, dùng `amend` hay `revert`? Vì sao?
3. Lỡ xóa nhánh, bạn tìm lại bằng cách nào?
4. Vì sao nên commit trước khi thử một việc có rủi ro?

Tiếp theo: [Bài 7: Quy trình cho repo tài liệu](07-quy-trinh-lam-viec-voi-repo-tai-lieu.md)
