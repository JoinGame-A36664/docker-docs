# 23. Sự khác biệt giữa Docker Compose và Docker Stack.

____
____

# <a name="content">Nội dung</a>

![https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg](https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg)

- Docker Compose và Docker Stack có thể được kiểm soát bởi một tập tin docker-compose.yml. Dưới đây là sự khác biệt giữa chúng.

- Docker Compose là một công cụ giúp bạn quản lý các Docker container bằng cách cho phép bạn định nghĩa mọi thứ thông qua tệp tin `docker-compose.yml`.

- `docker stack` là một lệnh được sử dụng trong Docker CLI. Nó cho phép bạn quản lý các Docker container thông qua Docker Swarm .

- Trong một số trường hợp, các tính năng nhất định chỉ hoạt động với `docker stack` và được bỏ qua bởi `Docker Compose` và các tính năng không được hỗ trợ của `Docker Compose` sẽ bị bỏ qua bởi lệnh `docker stack`.

- Ví dụ: thuộc tính `deploy` bị bỏ qua bởi `Docker Compose` và `depends_on` bị bỏ qua bởi `docker stack` . Có những khác biệt khác nữa. Bạn có thể tìm thấy chúng bằng cách kiểm tra [tại đây](https://docs.docker.com/compose/compose-file/).


> **Bổ sung (2026):** sau khi Compose chuyển sang Compose Specification (v2) thì ranh giới đã nhạt hơn:
> - `docker compose up` (v2) **có đọc** `deploy.resources` (giới hạn CPU/RAM) và `deploy.replicas`, không còn "bỏ qua toàn bộ `deploy`" như bản gốc.
> - Các phần `deploy.update_config`, `deploy.placement`, ... vẫn chỉ có tác dụng với `docker stack deploy` (Swarm).
> - `docker stack deploy` **không build image**: phần `build:` bị bỏ qua, bạn phải build và push image lên registry trước.
> - Quy tắc chọn: chạy trên **một máy** (dev, máy chủ nhỏ) → `docker compose`; chạy trên **cụm nhiều máy với Swarm** → `docker stack`. Với cụm lớn ngày nay đa phần chọn Kubernetes.

____

# <a name="content-others">Các nội dung khác</a>
