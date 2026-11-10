# Mục lục tài liệu

> **Bản cập nhật 2026.** Nội dung và cách trình bày của tài liệu gốc (ghi chép năm 2017-2018) được giữ nguyên. Những chỗ đã lỗi thời được sửa trực tiếp hoặc ghi chú bằng khối **"Cập nhật (2026)"** ngay tại chỗ đó. Có thêm bài mới và một dự án thực hành:
> - [Những điều đã thay đổi từ 2017 đến nay](/docs/docker-nangcao/docker-nhung-dieu-moi.md): bảng đối chiếu cách cũ và cách mới, đọc trước nếu bạn đã quen tài liệu cũ.
> - [Thực hành theo giai đoạn](/thuc-hanh/README.md): Dự án 1 "Sổ lưu bút Docker" (6 giai đoạn, từ `docker run` đến Docker Compose) và Dự án 2 "Kế hoạch đóng gói một web hoàn chỉnh" (9 bước).
> - [Kubernetes hiện nay: kind, kubeadm, Deployment đầu tiên](/docs/docker-nangcao/docker-kubernetes-hien-nay.md).
> - [Học Git đủ dùng](/docs/git/README.md): commit, nhánh, GitHub, hoàn tác, đánh số phiên bản.

## Cấu trúc repo

```
docker-docs/
├── docs/
│   ├── docker-5m/        giới thiệu nhanh (cài đặt, hoạt động, image, container)
│   ├── docker-coban/     lý thuyết cơ bản, chia thư mục theo chủ đề 01 → 11
│   │   ├── 01-cai-dat/            06-compose/
│   │   ├── 02-khai-niem-va-lenh/  07-registry/
│   │   ├── 03-image-va-dockerfile/ 08-swarm/
│   │   ├── 04-volume-va-du-lieu/  09-kubernetes/
│   │   └── 05-network/            10-demo/  11-khac/
│   ├── docker-nangcao/   chủ đề nâng cao, Kubernetes hiện nay, những điều đã thay đổi
│   ├── docker-tips/      các mẹo nhỏ
│   └── git/              học Git đủ dùng
├── thuc-hanh/            2 dự án thực hành theo giai đoạn
├── scripts/              script cài đặt và ví dụ
└── images/, tools/       hình ảnh, tài liệu tham khảo
```
Mục lục chi tiết của phần cơ bản: [docs/docker-coban/README.md](/docs/docker-coban/README.md).

## Giới thiệu docker
[Cài đặt docker](/docs/docker-5m/01.Caidatdocker.md)

[hoạt động của docker](/docs/docker-5m/02.Hoatdongcuadocker.md)

[Giới thiệu Image trong docker](/docs/docker-5m/03.Imagetrongdocker.md)

[Giới thiệu container trong](/docs/docker-5m/00.Gioithieuve-container-docker.md)
## 1. Docker cơ bản

---

### Cài đặt môi trường lab

Tài liệu cài đặt docker để chuẩn bị môi trường tìm hiểu lý thuyết và thực hành ở tài liệu.

[Cài đặt docker engine cơ bản](/docs/docker-coban/01-cai-dat/docker-thuchanh-caidat.md)

### Lý thuyết và có thực hành

[Các ghi chép cần chú ý về docker](/docs/docker-coban/02-khai-niem-va-lenh/ghichep-docker.md)

[Các lệnh hay sử dụng trong docker](/docs/docker-coban/02-khai-niem-va-lenh/ghichep-lenh-docker.md)

[Docker image](/docs/docker-coban/03-image-va-dockerfile/ghichep-docker-images.md)

[Viết dockerfile để build image](/docs/docker-coban/03-image-va-dockerfile/docker-dockerfile.md)

[Volume trong docker](/docs/docker-coban/04-volume-va-du-lieu/docker-volume.md)

[Network trong docker](/docs/docker-coban/05-network/docker-network.md)

[Viết docker-compose để khởi chạy multi container](/docs/docker-coban/06-compose/docker-compose.md)

[Docker swarm - tạo, quản lý cluster trong Docker](/docs/docker-coban/08-swarm/ghichep-docker-lenh-swarm.md)

### Thực hành ngoài lề

[Cài đặt docker engine cơ bản](/docs/docker-coban/01-cai-dat/docker-thuchanh-caidat.md)

[Thao tác với images](/docs/docker-coban/03-image-va-dockerfile/docker-thuchanh-images.md)

[Thao tác với container](/docs/docker-coban/02-khai-niem-va-lenh/docker-thuchanh-container.md)

[Thực hành với dockerfile](/docs/docker-coban/03-image-va-dockerfile/docker-thuchanh-dockerfile.md)

[Thực hành với docker volume](/docs/docker-coban/04-volume-va-du-lieu/docker-thuchanh-volume.md)

[Thực hành với docker network](/docs/docker-coban/05-network/docker-thuchanh-network.md)

[Thực hành với docker hub (docker registry)](/docs/docker-coban/07-registry/docker-deploy-private-registry.md)

### Demo Docker

[Demo - Sử dụng docker để tạo các container](/docs/docker-coban/10-demo/docker-demo.md)

## 2. Docker nâng cao

[sử dụng nginx](/docs/docker-nangcao/docker-nginx-ps.md)

[sử dụng supervisor](/docs/docker-nangcao/docker-supervisor.md)

[sử dụng volume](/docs/docker-nangcao/docker-volume.md)

[Kubernetes hiện nay: kind, kubeadm, Deployment đầu tiên (bài mới)](/docs/docker-nangcao/docker-kubernetes-hien-nay.md)

[Những điều đã thay đổi trong thế giới Docker từ 2017 đến nay (bài mới)](/docs/docker-nangcao/docker-nhung-dieu-moi.md)

## 3. Vài Tips về docker

<span style="color:yellow">Xem trong source :))</span>

Mục lục các tips: [docs/docker-tips/readme.md](/docs/docker-tips/readme.md)

## 4. Git: quản lý phiên bản tài liệu (bài mới)

[Học Git đủ dùng: commit, nhánh, GitHub, hoàn tác, quy trình làm việc](/docs/git/README.md)

## 5. Thực hành (bài mới)

[Thư mục thực hành: bản đồ và cách học](/thuc-hanh/README.md)

[Dự án 1: Sổ lưu bút Docker, 6 giai đoạn từ `docker run` đến Docker Compose](/thuc-hanh/du-an-1-so-luu-but/README.md)

[Dự án 2: Kế hoạch đóng gói một web hoàn chỉnh, 9 bước](/thuc-hanh/du-an-2-dong-goi-web-hoan-chinh/README.md)

[Bài tập sửa lỗi: script tự phá hệ thống để bạn luyện tìm lỗi và sửa (11 đề)](/thuc-hanh/bai-tap-sua-loi/README.md)
---
