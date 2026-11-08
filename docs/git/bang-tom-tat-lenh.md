# Bảng tóm tắt lệnh Git

Tra nhanh. Chi tiết xem trong từng bài.

## Bắt đầu
| Lệnh | Làm gì |
|---|---|
| `git clone <địa-chỉ>` | Tải repo từ GitHub về máy |
| `git init` | Biến thư mục hiện tại thành repo |
| `git config --global user.name "Ten"` | Khai báo tên |
| `git config --global user.email "mail"` | Khai báo email |

## Xem tình hình
| Lệnh | Làm gì |
|---|---|
| `git status -sb` | Xem file nào đã đổi, đang ở nhánh nào |
| `git diff` | Xem thay đổi chưa `add` |
| `git diff --staged` | Xem thay đổi đã `add` (sắp commit) |
| `git log --oneline -10` | 10 commit gần nhất, mỗi commit một dòng |
| `git log --oneline --graph --all` | Lịch sử có vẽ nhánh |
| `git show <ma>` | Chi tiết một commit |
| `git blame <file>` | Ai sửa dòng nào, khi nào |

## Lưu thay đổi
| Lệnh | Làm gì |
|---|---|
| `git add <file>` | Chọn file đưa vào commit |
| `git add -A` | Chọn tất cả thay đổi (cẩn thận) |
| `git commit -m "ghi chu"` | Lưu thành một điểm |
| `git mv <cu> <moi>` | Đổi tên/di chuyển file |
| `git rm <file>` | Xóa file khỏi repo |
| `git rm --cached <file>` | Ngừng theo dõi file nhưng giữ nó trên máy |

## Nhánh
| Lệnh | Làm gì |
|---|---|
| `git branch` | Liệt kê nhánh (dấu `*` là nhánh hiện tại) |
| `git branch --show-current` | In tên nhánh hiện tại |
| `git switch -c <ten>` | Tạo nhánh mới và chuyển sang |
| `git switch <ten>` | Chuyển nhánh |
| `git merge <ten>` | Gộp nhánh `<ten>` vào nhánh hiện tại |
| `git merge --abort` | Hủy việc gộp đang xung đột |
| `git branch -d <ten>` | Xóa nhánh đã gộp |
| `git branch -D <ten>` | Xóa nhánh bắt buộc (cẩn thận) |
| `git stash` / `git stash pop` | Cất tạm thay đổi / lấy lại |

## Làm việc với GitHub
| Lệnh | Làm gì |
|---|---|
| `git remote -v` | Xem địa chỉ remote |
| `git fetch` | Tải thông tin mới, chưa gộp |
| `git pull` | Tải và gộp vào nhánh hiện tại |
| `git push` | Đẩy commit lên GitHub |
| `git push -u origin <nhanh>` | Đẩy nhánh mới lần đầu và gắn theo dõi |
| `git push origin <tag>` | Đẩy một tag |

## Hoàn tác
| Lệnh | Làm gì |
|---|---|
| `git restore <file>` | Bỏ thay đổi chưa `add` của file |
| `git restore --staged <file>` | Bỏ file khỏi khu chuẩn bị |
| `git restore --source=<ma> <file>` | Lấy file từ commit cũ |
| `git commit --amend` | Sửa commit cuối (chưa push) |
| `git reset --soft HEAD~1` | Hủy commit cuối, giữ thay đổi (chưa push) |
| `git revert <ma>` | Tạo commit mới đảo ngược commit cũ (an toàn cho commit đã push) |
| `git switch --detach <ma>` | Xem dự án tại một thời điểm cũ |
| `git reflog` | Lịch sử mọi nơi HEAD từng đi qua (cứu hộ) |

## Phiên bản
| Lệnh | Làm gì |
|---|---|
| `git tag` | Liệt kê tag |
| `git tag -a v1.0.0 -m "ghi chu"` | Tạo tag có ghi chú |
| `git push origin v1.0.0` | Đẩy tag lên GitHub |
| `git switch --detach v1.0.0` | Xem lại dự án đúng ở phiên bản đó |

## Công thức dùng hằng ngày
```sh
git switch main && git pull             # bắt đầu
git switch -c docs/ten-viec             # nhánh mới
git status -sb && git diff              # xem trước khi lưu
git add <file> && git commit -m "..."   # lưu (lặp lại nhiều lần)
git push -u origin docs/ten-viec        # đẩy -> tạo Pull Request trên GitHub
git switch main && git pull             # sau khi đã gộp
git branch -d docs/ten-viec             # dọn
```

## Gặp tình huống này thì làm gì?
| Tình huống | Làm |
|---|---|
| Không biết đang ở đâu, cái gì thay đổi | `git status -sb` |
| Sửa nhầm file | `git restore <file>` |
| Commit sai ghi chú | `git commit --amend -m "..."` (chưa push) |
| Commit đã push mà sai | `git revert <ma>` rồi `git push` |
| `git push` bị từ chối | `git pull` rồi `git push` |
| Xung đột khi gộp | Sửa file, bỏ dấu `<<<<<<<`, `git add`, `git commit` (hoặc `git merge --abort`) |
| Lỡ commit mật khẩu | **Đổi mật khẩu ngay**; xóa file chỉ là chưa đủ |
| Cần chuyển nhánh gấp khi đang sửa dở | `git stash` rồi `git switch` |
