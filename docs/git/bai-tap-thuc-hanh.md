# Bài tập thực hành Git

Bạn sẽ làm trên **một thư mục thử riêng**, không đụng tới repo tài liệu thật. Nhờ vậy cứ thoải mái làm sai: xong thì xóa thư mục đi là hết.

> **Dùng Git Bash** (Windows) hoặc Terminal (macOS/Linux) cho các bài tập này. Một số lệnh như `echo "..." > file` ở Windows PowerShell cũ ghi file sai bảng mã, làm Git hiểu nhầm là file nhị phân.
> Đã cài và cấu hình Git chưa? Xem [bài 2](02-cai-dat-va-cau-hinh.md).

Mỗi bài có phần **"Bạn sẽ thấy"** để tự kiểm tra. Làm lần lượt từ bài 1.

---

## Bài 1. Tạo repo và commit đầu tiên
```sh
mkdir git-thu && cd git-thu
git init -b main
echo "Docker la cong cu chay ung dung trong container" > ghi-chu.txt
git status -sb
git add ghi-chu.txt
git commit -m "Them ghi chu dau tien"
git log --oneline
```
**Bạn sẽ thấy:** `git status -sb` hiện `?? ghi-chu.txt` (file mới chưa theo dõi). Sau commit, `git log --oneline` hiện **một dòng** gồm mã ngắn và ghi chú.

## Bài 2. Sửa, xem khác biệt, commit lần hai
```sh
echo "Image la khuon, container la thu duoc dung tu khuon" >> ghi-chu.txt
git status -sb
git diff
git add ghi-chu.txt
git diff --staged
git commit -m "Them ghi chu ve image va container"
git log --oneline
```
**Bạn sẽ thấy:** `git status -sb` hiện ` M ghi-chu.txt`; `git diff` có dòng bắt đầu bằng `+` cho dòng mới; sau commit, log có **hai** dòng.

## Bài 3. `.gitignore`
```sh
echo "mat-khau-bi-mat" > .env
echo "nhat ky tam" > chay.log
git status -sb
printf ".env\n*.log\n" > .gitignore
git status -sb
git add .gitignore
git commit -m "Them .gitignore"
```
**Bạn sẽ thấy:** lần `status` đầu thấy `.env` và `chay.log` ở dạng `??`. Sau khi tạo `.gitignore`, hai file đó **biến mất** khỏi danh sách và chỉ còn `?? .gitignore`.

Kiểm tra: `git check-ignore -v .env` sẽ in dòng của `.gitignore` đang chặn nó.

## Bài 4. Nhánh và gộp (fast-forward)
```sh
git switch -c docs/them-compose
echo "Compose chay nhieu container bang mot file" >> ghi-chu.txt
git add ghi-chu.txt
git commit -m "Them ghi chu ve Compose"
git log --oneline --graph --all
git switch main
cat ghi-chu.txt
```
**Bạn sẽ thấy:** khi đã quay về `main`, file `ghi-chu.txt` **không có** dòng về Compose (nó chỉ nằm trên nhánh kia). Tiếp tục:
```sh
git merge docs/them-compose
cat ghi-chu.txt
git branch -d docs/them-compose
git log --oneline --graph --all
```
**Bạn sẽ thấy:** Git báo `Fast-forward`; giờ `main` có dòng về Compose; nhánh đã bị xóa gọn gàng.

## Bài 5. Tạo và giải quyết xung đột
Tạo hai thay đổi khác nhau ở **cùng một dòng** trên hai nhánh:
```sh
echo "Tieu de: ghi chu Docker" > tieu-de.txt
git add tieu-de.txt && git commit -m "Them tieu de"

git switch -c nhanh-a
echo "Tieu de: Docker co ban" > tieu-de.txt
git add tieu-de.txt && git commit -m "Doi tieu de: co ban"

git switch main
echo "Tieu de: Docker cho nguoi moi" > tieu-de.txt
git add tieu-de.txt && git commit -m "Doi tieu de: cho nguoi moi"

git merge nhanh-a
```
**Bạn sẽ thấy:** `CONFLICT (content): Merge conflict in tieu-de.txt` và `Automatic merge failed`. Đừng hoảng.

Giải quyết:
```sh
git status -sb
cat tieu-de.txt
```
File chứa các dòng đánh dấu `<<<<<<<`, `=======`, `>>>>>>>`. Ghi đè bằng nội dung bạn muốn giữ (đã bỏ dấu đánh dấu), rồi hoàn tất:
```sh
echo "Tieu de: Docker co ban cho nguoi moi" > tieu-de.txt
git add tieu-de.txt
git commit -m "Gop tieu de hai nhanh"
git log --oneline --graph --all
```
**Bạn sẽ thấy:** log vẽ hai nhánh nhập lại thành một. Dọn: `git branch -d nhanh-a`.

*Muốn thử đường lui:* lặp lại bài này nhưng sau khi gặp `CONFLICT` thì gõ `git merge --abort` và quan sát mọi thứ về trạng thái trước khi gộp.

## Bài 6. Hoàn tác
**6a. Bỏ thay đổi chưa add**
```sh
echo "dong sai" >> ghi-chu.txt
git status -sb
git restore ghi-chu.txt
git status -sb
```
**Bạn sẽ thấy:** file trở lại như cũ, `status` sạch.

**6b. Sửa ghi chú commit cuối (chưa push)**
```sh
echo "them mot dong" >> ghi-chu.txt
git add ghi-chu.txt
git commit -m "ghi chu sai chinh ta"
git commit --amend -m "Them mot dong vao ghi chu"
git log --oneline -3
```
**Bạn sẽ thấy:** chỉ có **một** commit mới với ghi chú đã sửa (không phải hai).

**6c. Đảo ngược một commit bằng `revert`**
```sh
git log --oneline -3                     # nhớ mã của commit "Them mot dong vao ghi chu"
git revert --no-edit HEAD
git log --oneline -3
cat ghi-chu.txt
```
**Bạn sẽ thấy:** thêm một commit mới tên `Revert "..."`, và dòng vừa thêm đã biến mất khỏi file. Lịch sử cũ vẫn còn nguyên.

**6d. Tìm lại nhánh lỡ xóa bằng `reflog`**
```sh
git switch -c nhanh-quan-trong
echo "viec quan trong" > quan-trong.txt
git add quan-trong.txt && git commit -m "Viec quan trong"
git switch main
git branch -D nhanh-quan-trong           # lỡ tay xóa!
git reflog | head -5
```
Tìm dòng ghi `commit: Viec quan trong`; mã commit nằm ở **cột đầu tiên** của dòng đó (một chuỗi ngắn như `3f9a1c2`). Chép mã đó và tạo lại nhánh:
```sh
git switch -c nhanh-quan-trong <ma-commit-tim-duoc>
ls
```
**Bạn sẽ thấy:** file `quan-trong.txt` đã trở lại.

## Bài 7. Tag (đánh dấu phiên bản)
```sh
git switch main
git tag -a v1.0.0 -m "Ban dau tien"
git tag
git show v1.0.0 --stat
```
**Bạn sẽ thấy:** danh sách tag có `v1.0.0`; `git show` in ghi chú của tag và commit nó trỏ tới.

## Bài 8. Thực hành đẩy/kéo mà không cần GitHub
Ta dùng **một thư mục khác trên máy làm "remote" giả**:
```sh
cd ..                                                 # ra khỏi git-thu
git init --bare -b main git-thu-remote.git             # "máy chủ" giả (nhớ có -b main)
cd git-thu
git remote add origin ../git-thu-remote.git
git push -u origin main
git push origin --tags
git remote -v
```
Giờ giả làm **một người khác** clone về và đẩy thêm một thay đổi:
```sh
cd ..
git clone git-thu-remote.git git-thu-nguoi-khac
cd git-thu-nguoi-khac
git config user.name "Nguoi Khac"
git config user.email "nguoi.khac@example.com"
echo "Duoc them boi nguoi khac" >> ghi-chu.txt
git add ghi-chu.txt
git commit -m "Nguoi khac them mot dong"
git push
```
Quay lại thư mục của bạn và **kéo** thay đổi về:
```sh
cd ../git-thu
git pull
git log --oneline -3
cat ghi-chu.txt
```
**Bạn sẽ thấy:** `git pull` kéo về commit "Nguoi khac them mot dong" và file có thêm dòng đó.

Thử luôn trường hợp **bị từ chối**: ở thư mục `git-thu` sửa và commit một thay đổi, ở `git-thu-nguoi-khac` cũng sửa, commit và `git push` trước; rồi quay lại `git-thu` gõ `git push`. Git sẽ báo từ chối (`rejected`, gợi ý `fetch first`). Gõ `git pull` rồi `git push` lại là xong.

## Bài 9 (tùy chọn). Luyện trên repo thật mà vẫn an toàn
Trong repo tài liệu của bạn, **luôn làm trên nhánh riêng**:
```sh
git switch -c chore/luyen-git
# sửa nhỏ một chỗ trong README, git add, git commit
git switch main                  # main không bị ảnh hưởng
git branch -D chore/luyen-git    # bỏ nhánh luyện tập
```

## Dọn dẹp sau khi luyện tập
```sh
cd ..
rm -rf git-thu git-thu-remote.git git-thu-nguoi-khac
```
(Windows PowerShell: `Remove-Item -Recurse -Force git-thu, git-thu-remote.git, git-thu-nguoi-khac`)

## Bạn đã làm được gì?
Khởi tạo repo, commit, xem lịch sử, bỏ qua file, tạo và gộp nhánh, giải xung đột, hoàn tác bốn kiểu, đặt tag, đẩy và kéo giữa hai nơi. Đó là **gần như mọi thứ bạn cần hằng ngày**. Tra lệnh nhanh ở [Bảng tóm tắt lệnh](bang-tom-tat-lenh.md).
