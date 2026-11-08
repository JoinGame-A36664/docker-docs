# Bài 7: Quy trình làm việc với repo tài liệu

## Làm gì trong bài này
Ghép mọi thứ đã học thành **một quy trình dùng hằng ngày**, kèm cách đặt tên và đánh số phiên bản. Đây là bài bạn in ra dán cạnh màn hình.

## 7.1 Quy trình cho mỗi việc (6 bước)

```
 1. Cập nhật main ─► 2. Tạo nhánh ─► 3. Sửa + commit ─► 4. Đẩy nhánh ─► 5. Pull Request ─► 6. Gộp + dọn
```

```sh
# 1. Bắt đầu từ main mới nhất
git switch main
git pull

# 2. Tạo nhánh riêng cho việc này (tên theo mẫu: loại/mo-ta-ngan)
git switch -c docs/them-bai-git

# 3. Làm việc; commit thường xuyên, mỗi commit một việc
git status -sb
git diff
git add docs/git/
git commit -m "Them bai 01: Git la gi"
#   ... lặp lại ...

# 4. Đẩy nhánh lên GitHub
git push -u origin docs/them-bai-git

# 5. Trên GitHub: tạo Pull Request -> xem tab "Files changed" -> Merge

# 6. Về máy, cập nhật và dọn
git switch main
git pull
git branch -d docs/them-bai-git
```

## 7.2 Thói quen kiểm tra trước khi commit
Mỗi lần trước khi `git commit`, quét nhanh 3 thứ:
1. `git status -sb`: có file lạ không (file tạm, `.env`, ảnh chụp màn hình nháp)?
2. `git diff --staged`: nội dung sắp lưu đúng ý chưa?
3. Có mật khẩu, token, khóa nào lọt vào không? Nếu có, bỏ ra khỏi commit **ngay**.

Với repo tài liệu này còn một bước riêng: chạy bộ kiểm tra liên kết (nếu có) hoặc tự bấm thử vài link vừa sửa, nhất là sau khi di chuyển file.

## 7.3 Đặt tên nhánh và ghi chú commit (thống nhất cả nhóm)

**Nhánh**: `loai/mo-ta-ngan`, viết thường, nối bằng gạch ngang.

| Loại | Dùng cho | Ví dụ |
|---|---|---|
| `docs/` | Viết/sửa nội dung tài liệu | `docs/update-docker-2026` |
| `fix/` | Sửa lỗi (link hỏng, lệnh sai) | `fix/link-network` |
| `feat/` | Thêm mục lớn mới | `feat/thuc-hanh-du-an-2` |
| `chore/` | Dọn dẹp, sắp xếp lại | `chore/sap-xep-docker-coban` |

**Ghi chú commit**: động từ + việc đã làm, ngắn gọn.
```
Them bai Git: nhanh va gop nhanh
Sua loi lenh docker compose trong bai Network
Sap xep lai thu muc docker-coban theo chu de
Cap nhat huong dan cai Docker cho Ubuntu 24.04
```
Commit lớn có thể có phần mô tả dài hơn sau một dòng trống.

## 7.4 Kiểm soát phiên bản bằng tag
Commit có mã khó nhớ. Khi hoàn thành một mốc đáng kể (ví dụ "bản tài liệu 2026 hoàn chỉnh"), đặt cho commit đó một **tag** có tên dễ nhớ:

```sh
git switch main && git pull
git tag -a v1.0.0 -m "Ban tai lieu Docker 2026 hoan chinh"      # tag có ghi chú
git push origin v1.0.0                                           # đẩy tag lên GitHub
git tag                                                          # liệt kê tag
git show v1.0.0                                                  # xem tag trỏ vào đâu
```
Muốn xem lại tài liệu đúng như lúc phát hành `v1.0.0`: `git switch --detach v1.0.0` (về lại: `git switch main`).

Cách đánh số gợi ý **MAJOR.MINOR.PATCH**:
| Số | Tăng khi | Ví dụ |
|---|---|---|
| MAJOR (số đầu) | Thay đổi lớn về cấu trúc | `2.0.0`: xếp lại toàn bộ thư mục |
| MINOR (số giữa) | Thêm nội dung mới | `1.1.0`: thêm bài Git |
| PATCH (số cuối) | Sửa lỗi nhỏ | `1.0.1`: sửa link hỏng |

Trên GitHub, từ tag bạn có thể bấm **Releases → Draft a new release** để tạo trang phát hành có ghi chú thay đổi và tệp đính kèm.

## 7.5 Việc nên làm một lần cho repo
| Việc | Cách |
|---|---|
| Chặn đẩy thẳng vào `main` | GitHub → Settings → Branches → rule cho `main`: yêu cầu Pull Request |
| Bỏ qua file không nên theo dõi | Tạo `.gitignore` (bài 3) |
| Giữ xuống dòng đúng cho script | `.gitattributes` với `*.sh text eol=lf` (repo này đã có) |
| Mô tả repo | Viết `README.md` ở gốc: repo là gì, đọc từ đâu |
| Không đưa file nặng/riêng tư lên | Cân nhắc trước khi `add` file PDF, ảnh lớn, dữ liệu thật (đã lên GitHub thì rất khó gỡ khỏi lịch sử) |

## 7.6 Khi làm việc nhóm
- Mỗi người một nhánh; **không** commit trực tiếp vào `main`.
- `git pull` trước khi bắt đầu, `git push` sau khi xong.
- Nhánh sống ngắn: làm xong việc nhỏ thì gộp, đừng để một nhánh tồn tại hàng tháng.
- Gặp xung đột: nói chuyện với người kia để chọn bản đúng, đừng đoán.
- Dùng Pull Request để xem lại code/tài liệu của nhau.

## 7.7 Áp dụng cho repo này
Repo có nhánh `master` (nhánh chính gốc) và nhánh `docs/update-docker-2026` (đợt cập nhật 2026). Để đưa đợt cập nhật vào nhánh chính:
```sh
git push -u origin docs/update-docker-2026      # đẩy nhánh lên GitHub
# GitHub: tạo Pull Request  base = master  <-  compare = docs/update-docker-2026
# xem "Files changed", rồi Merge
git switch master && git pull
git tag -a v2026.1 -m "Cap nhat tai lieu Docker 2026"
git push origin v2026.1
```

## Tự kiểm tra
1. Vì sao mỗi việc nên có một nhánh riêng?
2. Trước khi commit bạn kiểm tra những gì?
3. Tag khác nhánh ở điểm nào? (Gợi ý: một cái đứng yên, một cái di chuyển cùng công việc.)
4. Số phiên bản nào bạn đặt khi chỉ sửa vài link hỏng?

Tiếp theo: [Bảng tóm tắt lệnh](bang-tom-tat-lenh.md) và [Bài tập thực hành](bai-tap-thuc-hanh.md)
