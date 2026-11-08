# Docker cơ bản: mục lục theo chủ đề

Các bài đã được xếp vào **từng thư mục theo chủ đề**. Số đầu tên thư mục là **thứ tự nên học**. Trong mỗi thư mục có `README.md` giới thiệu chủ đề và thứ tự đọc.

| Thư mục | Chủ đề | Bạn sẽ học được |
|---|---|---|
| [01-cai-dat](01-cai-dat/README.md) | Cài đặt | Cài Docker lên máy, thử container đầu tiên |
| [02-khai-niem-va-lenh](02-khai-niem-va-lenh/README.md) | Khái niệm và câu lệnh | Docker là gì, các lệnh hay dùng, thao tác với container |
| [03-image-va-dockerfile](03-image-va-dockerfile/README.md) | Image và Dockerfile | Tìm, tải, tự tạo image bằng Dockerfile |
| [04-volume-va-du-lieu](04-volume-va-du-lieu/README.md) | Volume và dữ liệu | Giữ dữ liệu khi container bị xóa, sao lưu |
| [05-network](05-network/README.md) | Mạng | Cho các container nói chuyện với nhau và với bên ngoài |
| [06-compose](06-compose/README.md) | Docker Compose | Chạy nhiều container bằng một file |
| [07-registry](07-registry/README.md) | Registry riêng | Dựng kho chứa image của riêng mình |
| [08-swarm](08-swarm/README.md) | Docker Swarm | Chạy trên cụm nhiều máy |
| [09-kubernetes](09-kubernetes/README.md) | Kubernetes | Cài Kubernetes (bài cũ; bài mới ở `docker-nangcao`) |
| [10-demo](10-demo/README.md) | Demo | Chạy thử WordPress, Drupal, Zabbix, RabbitMQ |
| `11-khac/` | Tài nguyên khác | File cấu hình tô màu Markdown cho Notepad++ |

## Gợi ý lộ trình
1. Học theo thứ tự `01` → `07` (nền tảng), kết hợp làm [thực hành](../../thuc-hanh/README.md).
2. `08-swarm` và `09-kubernetes` là phần mở rộng, đọc sau khi đã quen Compose.
3. `10-demo` để tham khảo thêm.

## Bảng đối chiếu: tên file cũ → vị trí mới
Nếu bạn có đánh dấu (bookmark) hoặc ghi chú trỏ tới đường dẫn cũ, tra bảng này. Tên file được **giữ nguyên**, chỉ thêm tên thư mục chủ đề.

| Thư mục mới | Các file bên trong |
|---|---|
| `01-cai-dat/` | `docker-thuchanh-caidat.md` |
| `02-khai-niem-va-lenh/` | `ghichep-docker.md`, `ghichep-lenh-docker.md`, `docker-thuchanh-container.md`, `lab-example.md` |
| `03-image-va-dockerfile/` | `ghichep-docker-images.md`, `docker-thuchanh-images.md`, `docker-dockerfile.md`, `docker-thuchanh-dockerfile.md` |
| `04-volume-va-du-lieu/` | `docker-volume.md`, `docker-thuchanh-volume.md`, `docker-coban-backup-and-recovery-containers.md`, `docker-plugin-rexray.md` |
| `05-network/` | `docker-network.md`, `docker-thuchanh-network.md` |
| `06-compose/` | `docker-compose.md`, `docker-dockercompose.md` |
| `07-registry/` | `docker-deploy-private-registry.md` |
| `08-swarm/` | `docker-swarm-about.md`, `docker-swarm-create.md`, `ghichep-docker-lenh-swarm.md`, `docker-thuchanh-caidat-docker-swarm.md`, `docker-swarm-wordpress.md` |
| `09-kubernetes/` | `docker-thuchanh-caidat-kubernetes.md` |
| `10-demo/` | `docker-demo.md`, `caidat-zabbix-agent.txt` |
| `11-khac/` | `md_default.xml` |
