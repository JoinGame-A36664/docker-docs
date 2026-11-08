# 20. Sử dụng Docker mà không cần sudo trên Linux

____
____

# <a name="content">Nội dung</a>

- ![https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg](https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg)

- Bài viết nói về việc quản lý Docker với một user không phải là root. Dưới đây sẽ là cách thực hiện:

- Theo mặc định khi cài Docker trên Linux. Ta chỉ có thể truy cập đến Docker daemon khi là người dùng `root` hoặc phải có thêm `sudo` trong các câu lệnh. Vậy khi ta không có quyền `root` thì phải làm như thế nào?

- *Hãy thêm một `docker group` và sau đó thêm user tới group đó:*

        sudo groupadd docker
        sudo usermod -aG docker $USER

    *hãy thực hiện đăng xuất ra khỏi Docker host và sau đó kiểm tra xem có hiệu lực hay chưa*.


> **Bổ sung (2026):**
> - Lưu ý bảo mật: thành viên của group `docker` **có quyền tương đương `root`** trên máy chủ (vì có thể chạy container mount `/` của host). Chỉ thêm người bạn tin tưởng, và không dùng cách này cho máy chủ nhiều người dùng.
> - Hiện nay có lựa chọn an toàn hơn là **Rootless mode**: chính Docker daemon chạy bằng user thường, không cần `root` ở bất kỳ bước nào sau khi cài. Cài (trên Ubuntu cần gói `uidmap`):
>
>       sudo apt-get install -y uidmap dbus-user-session
>       dockerd-rootless-setuptool.sh install
>       systemctl --user enable --now docker
>       export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
>
>   Hạn chế: không publish được port dưới 1024 (trừ khi cấu hình thêm), một số network driver bị giới hạn. Đổi lại, nếu container bị khai thác thì kẻ tấn công không có `root` trên host.
> - Cách khác đáng biết: **Podman** cũng chạy container không cần daemon và không cần root, dùng gần như cùng lệnh (`podman run`, `podman build`).

____

# <a name="content-others">Các nội dung khác</a>
