# Những điều đã thay đổi trong thế giới Docker (từ 2017 đến nay)

> Bài bổ sung. Tài liệu gốc ghi chép từ khoảng 2017 đến 2018. Bài này tóm tắt những gì đã đổi, để bạn đọc các bài khác mà không bị "lạc nhịp". Từng bài cũng có ghi chú **Cập nhật (2026)** ngay tại chỗ có khác biệt.

____

# Mục lục
- [1. Bảng đối chiếu: cách cũ → cách mới](#table)
- [2. Compose v2](#compose)
- [3. Build image: BuildKit, buildx, đa kiến trúc](#build)
- [4. Bảo mật chuỗi cung ứng: quét lỗ hổng, SBOM, ký image](#supply)
- [5. Chạy container an toàn hơn](#harden)
- [6. Docker Desktop, WSL 2 và các công cụ thay thế](#desktop)
- [7. Kubernetes không còn dùng Docker Engine trực tiếp](#k8s)
- [8. Nên học gì tiếp theo](#next)

____

# <a name="table">1. Bảng đối chiếu: cách cũ → cách mới</a>

| Trong tài liệu gốc | Hiện nay |
|---|---|
| Ubuntu 14.04 / 16.04, CentOS 7 | Ubuntu 22.04 / 24.04, Debian 12, Rocky / AlmaLinux 9 |
| `apt-key add` + `add-apt-repository` để thêm kho Docker | Khóa lưu trong `/etc/apt/keyrings/`, khai báo `signed-by=` (xem [Cài đặt docker](../docker-5m/01.Caidatdocker.md)) |
| `docker-compose` (v1, Python, cài bằng `pip` hoặc `curl`) | `docker compose` (v2, plugin của Docker CLI, đi kèm Docker) |
| `version: '2'` / `'3'` đầu file compose | Bỏ dòng `version`, theo Compose Specification |
| `docker-compose.yml` | `compose.yaml` (tên cũ vẫn đọc được) |
| `docker-compose scale svc=3` | `docker compose up -d --scale svc=3` |
| `links:` / `--link` | Dùng user-defined network, gọi nhau bằng tên |
| `MAINTAINER` trong Dockerfile | `LABEL maintainer="..."` |
| `ENV KEY value` | `ENV KEY=value` |
| `.dockerfileignore` (ghi nhầm) | `.dockerignore` |
| `FROM image:latest` hoặc không tag | Ghim phiên bản, có thể thêm digest |
| `/etc/default/docker` với `DOCKER_OPTS` | `/etc/docker/daemon.json` |
| `service docker restart` | `sudo systemctl restart docker` |
| `ifconfig`, `route -n`, `netstat` | `ip a`, `ip route`, `ss -tulpn` |
| `docker-machine` | Đã ngừng phát triển. Dùng Docker Desktop, hoặc `docker context` để điều khiển Docker trên máy từ xa qua SSH |
| `docker scan` (từng có sẵn) | `docker scout` (và Trivy, Grype...) |
| `docker run` kiểu `-v /host:/ct` ở mọi chỗ | `--mount` rõ ràng hơn; named volume cho dữ liệu, bind mount cho mã nguồn khi phát triển |
| Docker Trusted Registry | Harbor, `ghcr.io`, ECR, GAR, ACR... |
| `mysql:5.7`, `node:8`, `php5` | Dùng bản còn được hỗ trợ (ví dụ `mysql:8.0`, `node:22`) |
| RexRay, Flocker (volume plugin) | Volume `local` với NFS, hoặc CSI driver / plugin của nhà cung cấp |

# <a name="compose">2. Compose v2</a>
- Là một **plugin viết bằng Go** của Docker CLI. Lệnh: `docker compose ...`. Bản v1 (`docker-compose`) đã ngừng hỗ trợ từ tháng 7/2023.
- Một đặc tả duy nhất, không còn phân biệt `2.x` và `3.x`. Mọi tính năng (`healthcheck`, `depends_on.condition`, `profiles`, `secrets`, `develop.watch`...) dùng được trên một máy đơn.
- Các điểm mới đáng dùng ngay: `depends_on` + `service_healthy`, `docker compose watch`, `include`, `profiles`, file `.env`, `compose.override.yaml`.
- Chi tiết: [Docker Compose](../docker-coban/06-compose/docker-compose.md) và [Cách viết Compose file](../docker-coban/06-compose/docker-dockercompose.md).

# <a name="build">3. Build image: BuildKit, buildx, đa kiến trúc</a>
- **BuildKit** là bộ máy build mặc định (từ Docker 23.0): build song song, cache thông minh, có `--mount=type=cache` và `--mount=type=secret`.
- **buildx** cho phép build một lần ra image chạy được trên nhiều CPU (amd64 cho máy chủ, arm64 cho Apple Silicon, Raspberry Pi, một số máy chủ đám mây):
  ```sh
  docker buildx build --platform linux/amd64,linux/arm64 -t user/app:1.0 --push .
  ```
- Hệ quả thực tế: nếu bạn dùng Mac chip M và máy chủ là x86, image build ra có thể **không chạy** ở máy chủ nếu quên `--platform`. Lỗi điển hình: `exec format error`.
- **Multi-stage build** là kỹ thuật bắt buộc phải biết để có image nhỏ, xem mục 3.19 bài [Dockerfile](../docker-coban/03-image-va-dockerfile/docker-dockerfile.md).
- `docker init` tạo sẵn Dockerfile, `.dockerignore`, `compose.yaml` cho dự án của bạn.

# <a name="supply">4. Bảo mật chuỗi cung ứng: quét lỗ hổng, SBOM, ký image</a>
Image bạn chạy chứa hàng trăm gói phần mềm của người khác. Ba việc nên làm quen:
1. **Quét lỗ hổng (CVE)**: `docker scout quickview <image>`, hoặc Trivy: `trivy image <image>`.
2. **SBOM** (danh sách thành phần phần mềm có trong image): `docker scout sbom <image>` hoặc build với `--sbom=true`.
3. **Ký và xác minh image** (ví dụ công cụ cosign của dự án Sigstore) để biết image đúng là do bạn / đội bạn build.

Kèm theo: dùng image chính thức (*Docker Official Image*, *Verified Publisher*), ghim phiên bản và digest, và build lại image định kỳ để nhận bản vá của hệ điều hành gốc.

# <a name="harden">5. Chạy container an toàn hơn</a>
Mặc định container chạy bằng `root` bên trong và có khá nhiều quyền. Các cờ sau thu hẹp quyền mà vẫn chạy được hầu hết ứng dụng web:

```sh
docker run -d --name web \
  --user 10001:10001 \
  --read-only --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --memory 256m --cpus 0.5 --pids-limit 200 \
  -p 127.0.0.1:8000:8000 \
  myapp:1.0
```
| Cờ | Tác dụng |
|---|---|
| `--user` | Không chạy bằng root |
| `--read-only` + `--tmpfs /tmp` | Hệ thống file chỉ đọc, chỉ cho ghi vào chỗ cần thiết |
| `--cap-drop ALL` | Bỏ toàn bộ Linux capability (thêm lại từng cái cần bằng `--cap-add`) |
| `--security-opt no-new-privileges` | Tiến trình con không leo thang đặc quyền |
| `--memory`, `--cpus`, `--pids-limit` | Chặn một container ngốn hết tài nguyên máy chủ |
| `-p 127.0.0.1:...` | Chỉ mở cổng ở localhost (xem mục bảo mật trong bài [Network](../docker-coban/05-network/docker-network.md)) |

Trong Compose các cờ này là `user`, `read_only`, `tmpfs`, `cap_drop`, `security_opt`, `deploy.resources`, `pids_limit`. Cũng đừng bao giờ: mount `/var/run/docker.sock` vào container không tin cậy, dùng `--privileged` cho ứng dụng bình thường, hay đưa mật khẩu vào image.

Bí mật: dùng `secrets` của Compose / Swarm / Kubernetes (file tại `/run/secrets/...`) thay vì biến môi trường khi có thể; biến môi trường hay bị lộ qua `docker inspect` và log.

Muốn an toàn hơn nữa ở mức daemon: **Rootless mode** (xem tip [chạy docker không cần root](../docker-tips/docker-run-without-root.md)).

# <a name="desktop">6. Docker Desktop, WSL 2 và các công cụ thay thế</a>
- Trên Windows và macOS, bạn chạy Docker qua **Docker Desktop**: một máy ảo Linux nhỏ bên trong, kèm giao diện, Compose, buildx, Kubernetes tùy chọn. Windows dùng backend **WSL 2** (Windows 11 Home chạy được).
- Điều khoản giấy phép của Docker Desktop áp dụng khác nhau cho cá nhân / học tập / doanh nghiệp lớn; hãy đọc trang giá của Docker khi dùng trong công ty.
- Hệ quả khi dùng trên Windows / macOS: `macvlan` và việc truy cập thẳng IP container từ máy host không dùng như trên Linux; bind mount từ ổ Windows chậm; file `.sh` phải có dòng kết thúc LF (xem `.gitattributes` trong repo này).
- Lựa chọn thay thế cùng dùng chuẩn image OCI: **Podman** (không daemon, rootless mặc định, lệnh gần giống `docker`), **containerd + nerdctl**, **Rancher Desktop**, **Colima** (macOS). Bạn học Docker thì chuyển sang các công cụ này rất nhanh.

# <a name="k8s">7. Kubernetes không còn dùng Docker Engine trực tiếp</a>
- Từ Kubernetes 1.24, `dockershim` bị gỡ bỏ. Runtime là **containerd** hoặc **CRI-O**. Image bạn build bằng Docker vẫn chạy bình thường vì cùng chuẩn OCI.
- Cài và dùng thử: bài [Kubernetes hiện nay](docker-kubernetes-hien-nay.md) (kind, kubeadm, Deployment đầu tiên).
- Docker Swarm vẫn còn nhưng ít được phát triển thêm; xem nhận định ở cuối bài [Giới thiệu Docker Swarm](../docker-coban/08-swarm/docker-swarm-about.md).

# <a name="next">8. Nên học gì tiếp theo</a>
1. Làm trọn hai dự án trong [`thuc-hanh/`](../../thuc-hanh/README.md): Dự án 1 (6 giai đoạn) rồi Dự án 2 (kế hoạch đóng gói một web hoàn chỉnh).
2. CI/CD: tự động build, quét lỗ hổng và đẩy image mỗi khi push code (GitHub Actions có sẵn các action `docker/build-push-action`, `docker/setup-buildx-action`).
3. Registry riêng (Harbor) hoặc `ghcr.io`.
4. Kubernetes cơ bản: Pod, Deployment, Service, Ingress, ConfigMap, Secret, PersistentVolume, Helm.
5. Quan sát hệ thống: log tập trung, metrics (Prometheus + Grafana), healthcheck.
