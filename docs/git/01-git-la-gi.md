# Bài 1: Git là gì?

## Vấn đề Git giải quyết
Bạn từng làm kiểu này chưa?
```
baocao.docx
baocao-final.docx
baocao-final-that-su.docx
baocao-final-that-su-sua-lan-3.docx
```
Git thay tất cả bằng **một file duy nhất** và một **lịch sử** ghi lại mỗi lần thay đổi: ai sửa, sửa gì, lúc nào, vì sao. Cần bản cũ thì lấy lại, cần so hai bản thì Git chỉ ra khác chỗ nào.

Git còn cho phép nhiều người cùng sửa một dự án mà không ghi đè lên nhau.

## Ba "vùng" bạn cần nhớ

```
┌──────────────────┐  git add   ┌──────────────────┐ git commit ┌──────────────────┐
│ 1. Thư mục       │ ─────────► │ 2. Khu chuẩn bị  │ ─────────► │ 3. Kho lịch sử   │
│    làm việc      │            │  (staging)       │            │  (repository)    │
│ file bạn đang sửa│            │ file đã chọn để  │            │ các điểm lưu     │
│                  │            │ đưa vào điểm lưu │            │ (commit)         │
└──────────────────┘            └──────────────────┘            └──────────────────┘
```
Hình dung việc **chụp ảnh tập thể**:
1. Mọi người đang đứng lộn xộn (thư mục làm việc).
2. Bạn **chọn ai vào khung hình** (`git add`, khu chuẩn bị).
3. Bạn **bấm máy** (`git commit`), tấm ảnh được cất vào album (kho lịch sử).

Vì sao có bước 2? Vì bạn có thể sửa 5 file nhưng chỉ muốn lưu 2 file trong lần này, để mỗi điểm lưu chỉ nói về **một việc**.

## Các từ cơ bản

| Từ | Nghĩa dễ hiểu |
|---|---|
| **Repository (repo)** | Thư mục dự án mà Git đang theo dõi. Có thêm một thư mục ẩn `.git` chứa toàn bộ lịch sử |
| **Commit** | Một điểm lưu: ảnh chụp toàn bộ dự án tại một thời điểm, kèm ghi chú và tên người lưu. Mỗi commit có một mã dài (ví dụ `a6da88b`) |
| **Branch (nhánh)** | Một đường làm việc riêng. Nhánh chính thường tên `main` hoặc `master` |
| **HEAD** | Dấu "bạn đang đứng ở đâu": thường là đầu của nhánh hiện tại |
| **Remote** | Bản sao repo đặt trên mạng (thường là GitHub). Tên mặc định là `origin` |
| **Clone** | Tải cả repo (kèm toàn bộ lịch sử) từ remote về máy |
| **Push** | Đẩy các commit của bạn **lên** remote |
| **Pull** | Kéo các commit mới **từ** remote về máy |
| **Merge** | Gộp một nhánh vào nhánh khác |
| **Pull Request (PR)** | Trên GitHub: lời đề nghị "hãy xem và gộp nhánh của tôi vào nhánh chính" |
| **Tag** | Nhãn đặt tên cho một commit quan trọng, ví dụ phiên bản `v1.0` |

## Git khác GitHub thế nào?
- **Git** là phần mềm chạy trên máy bạn, quản lý lịch sử.
- **GitHub** là website lưu repo của Git trên mạng, thêm giao diện, Pull Request, phân quyền... (Cũng có GitLab, Bitbucket, Gitea tương tự.)

Bạn có thể dùng Git hoàn toàn không cần GitHub. Nhưng GitHub giúp sao lưu và chia sẻ.

## Ví dụ lịch sử của repo này
Gõ trong thư mục repo:
```sh
git log --oneline -5
```
Bạn sẽ thấy một dãy commit, mỗi dòng là một điểm lưu (mã ngắn + ghi chú). Đó chính là "album" của dự án.

## Tự kiểm tra
1. Vì sao có khu chuẩn bị (staging) nằm giữa thư mục làm việc và kho lịch sử?
2. Commit khác "lưu file" (Ctrl+S) thế nào?
3. Nhánh dùng để làm gì?

Tiếp theo: [Bài 2: Cài đặt và cấu hình](02-cai-dat-va-cau-hinh.md)
