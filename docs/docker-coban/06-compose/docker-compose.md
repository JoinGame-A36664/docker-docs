# Docker Compose
- Compose là công cụ giúp định nghĩa và khởi chạy multi-container Docker applications.
- Chỉ với một câu lệnh, ta có thể dễ dàng create và start toàn bộ các services phục vụ cho việc chạy ứng dụng.

- Việc sử dụng Docker Compose được tóm lược trong 3 bước cơ bản sau:
  - Khai báo app’s environment với Dockerfile.
  - Khai báo các services cần thiết để chạy app trong docker-compose.yml.
  - Run `docker compose up` và Compose sẽ start và run app.

> **Cập nhật (2026):** những thay đổi quan trọng nhất của Compose kể từ bản gốc của tài liệu này:
> - **Compose v2** viết bằng Go và là một **plugin của Docker CLI**. Lệnh là `docker compose` (có dấu cách), thay cho `docker-compose` (có dấu gạch ngang, bản v1 viết bằng Python, đã ngừng hỗ trợ từ tháng 7/2023).
> - Khóa `version:` ở đầu file **không còn cần thiết** và bị coi là lỗi thời (obsolete). Compose v2 theo đặc tả **Compose Specification** thống nhất, không còn chia version 2.x và 3.x. Nếu bạn vẫn để `version: '3'` thì chạy được nhưng sẽ có cảnh báo.
> - `docker-compose.yml` vẫn được đọc, nhưng tên file ưu tiên hiện nay là `compose.yaml` (hoặc `compose.yml`).
> - Lệnh `scale` riêng đã bỏ, dùng `docker compose up --scale <service>=<n>`.
>
> Các phần bên dưới đã được sửa theo hướng đó, kèm ghi chú ở chỗ khác biệt.

# 1. Cài đặt
- Với Docker Engine cài theo hướng dẫn mới (gói `docker-compose-plugin`) hoặc Docker Desktop, Compose **đã có sẵn**. Kiểm tra:
```sh
docker compose version
```

- Nếu chưa có (ví dụ cài Docker bằng cách cũ trên Ubuntu/Debian):
```sh
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
```

- Cách cài cũ trong tài liệu gốc (`pip install docker-compose` và tải `run.sh` bản 1.11.2) là Compose v1, **không còn được khuyến nghị**. Nếu máy bạn còn lệnh `docker-compose` cũ, có thể chạy song song nhưng nên chuyển sang `docker compose`.

# 2. Ví dụ chạy wordpress.
Chúng ta sẽ tạo ra 2 containers, 1 containers chứa mã nguồn wordpress và 1 containers chưa cơ sở dữ liệu mysql. Bằng cách định nghĩa trong file compose. Chỉ với 1 dòng lệnh khởi tạo, docker sẽ lập tức tạo ra 2 containers và sẵn sàng cho chúng ta dựng lên wordpress, một cách nhanh chóng.

- Đoạn mã compose: Viết theo cú pháp **YAML**.
```yaml
services:
   db:
     image: mysql:8.0
     volumes:
       - db_data:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: wordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress
     healthcheck:
       test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-pwordpress"]
       interval: 5s
       timeout: 3s
       retries: 20

   wordpress:
     depends_on:
       db:
         condition: service_healthy
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress
       WORDPRESS_DB_NAME: wordpress

volumes:
   db_data:
```

> **Cập nhật (2026):** so với bản gốc (`version: '2'`, `mysql:5.7`) file trên đã đổi 4 chỗ: bỏ dòng `version`; dùng `mysql:8.0` vì 5.7 đã hết hỗ trợ từ 10/2023; dùng **named volume** `db_data` thay vì bind mount `./data` (tránh lỗi phân quyền, nhất là trên Windows/macOS); và thêm `healthcheck` để `wordpress` chỉ chạy khi MySQL thực sự sẵn sàng.

- (Bản gốc có dòng `version: '2'`: chỉ ra phiên bản file compose. Hiện nay bỏ đi, xem ghi chú ở đầu bài.)
- `services:`: Trong mục services, chỉ ra những services (containers) mà ta sẽ cài đặt. Ở đây, tạo sẽ tạo ra services tương ứng với 2 containers là db và wordpress.
- Trong services db: 
  - image: chỉ ra image sẽ được sử dụng để create containers. Ngoài ra, bạn có thể viết dockerfile và khai báo lệnh `build` để containers sẽ được create từ dockerfile.
  - volumes: mount volume `db_data` (do Docker quản lý, khai báo ở mục `volumes:` cuối file) với thư mục /var/lib/mysql trong container. Dữ liệu nằm lại sau khi container bị xóa. Cách cũ của bản gốc là bind mount thư mục `./data` trên host (cùng thư mục chứa file compose), vẫn dùng được.
  - healthcheck: lệnh kiểm tra MySQL đã sẵn sàng nhận kết nối chưa. Docker chạy định kỳ và gán trạng thái `healthy` / `unhealthy` cho container.
  - restart: always: Tự động khởi chạy khi container bị shutdown.
  - environment: Khai báo các biến môi trường cho container. Cụ thể là thông tin cơ sở dữ liệu.
- Trong services wordpress:
  - depends_on: db: Chỉ ra sự phụ thuộc của services wordpress với services db. Tức là services db phải chạy và tạo ra trước, thì services wordpress mới chạy. Lưu ý: dạng ngắn (`- db`) chỉ đợi container db **được khởi chạy**, chưa chắc MySQL đã sẵn sàng. Dạng dài `condition: service_healthy` (như ví dụ trên) mới đợi tới khi healthcheck báo `healthy`.
  - ports: Forwards the exposed port 80 của container sang port 8000 trên host machine.
  - environment: Khai báo các biến môi trường. Sau khi tạo ra db ở container trên, thì sẽ lấy thông tin đấy để cung cấp cho container wordpress (chứa source code).

- Khởi chạy
```sh
root@adk:/opt/test# docker compose up -d
```
(thêm `-d` để chạy nền; bỏ `-d` thì log hiển thị trực tiếp và `Ctrl+C` sẽ dừng stack)

- Kết quả (ví dụ bản gốc dùng `docker-compose ps` của Compose v1, tên container dạng `test_db_1` với dấu gạch dưới. Compose v2 đặt tên dạng `test-db-1` với dấu gạch ngang, và cột hiển thị gọn hơn. Kết quả dưới đây chỉ minh họa dạng hiển thị, không phải log chạy thật.)
```sh
root@adk:/opt/test# docker compose ps
NAME               IMAGE              COMMAND                  SERVICE     STATUS                    PORTS
test-db-1          mysql:8.0          "docker-entrypoint.s…"   db          Up 2 minutes (healthy)    3306/tcp, 33060/tcp
test-wordpress-1   wordpress:latest   "docker-entrypoint.s…"   wordpress   Up 2 minutes              0.0.0.0:8000->80/tcp
```
Mở trình duyệt vào `http://localhost:8000` để thấy trang cài đặt WordPress.

```sh
root@adk:/opt/test/data# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
54cfd8a41b73        wordpress:latest    "docker-entrypoint..."   7 minutes ago       Up 7 minutes        0.0.0.0:8080->80/tcp     test_wordpress_1
68460ffee3c4        mysql:5.7           "docker-entrypoint..."   7 minutes ago       Up 7 minutes        3306/tcp                 test_db_1
```

# 3. Một vài chú ý:
- dockerfile dùng để build các image.
- docker-compose dùng để build và run các container.
- docker-compose viết theo cú pháp **YAML**, các lệnh khai báo trong docker-compose gần tương tự với thao tác chạy container `docker run`.
- docker compose cung cấp chức năng `Horizontally scaled`, cho phép ta tạo ra nhiều container giống nhau một cách nhanh chóng. Bằng cách sử dụng lệnh
```sh
docker compose up -d --scale name_service=5
```

Trong đó, **name_service** là tên services cần tạo container. **5** là số container sẽ được tạo ra. (Lệnh cũ `docker-compose scale` đã bị loại bỏ. Khi scale, không được đặt `container_name` cố định và không được map cứng một port host cho service đó, nếu không các bản sao sẽ tranh nhau.)

## Các lệnh Compose hay dùng
| Lệnh | Tác dụng |
|---|---|
| `docker compose up -d` | Tạo và chạy toàn bộ service ở chế độ nền |
| `docker compose up -d --build` | Build lại image trước khi chạy |
| `docker compose ps` | Xem trạng thái các service |
| `docker compose logs -f <service>` | Xem log liên tục của một service |
| `docker compose exec <service> sh` | Vào trong container đang chạy |
| `docker compose run --rm <service> <lệnh>` | Chạy một lệnh một lần trong container mới |
| `docker compose stop` / `start` | Dừng / chạy lại, giữ nguyên container |
| `docker compose down` | Dừng và xóa container, network (giữ volume) |
| `docker compose down -v` | Như trên và xóa luôn volume (mất dữ liệu!) |
| `docker compose config` | Kiểm tra và in file compose sau khi gộp biến môi trường |
| `docker compose watch` | Tự đồng bộ file / rebuild khi bạn sửa code (xem mục dưới) |

## Biến môi trường và file `.env`
Thay vì ghi mật khẩu thẳng vào file compose, tạo file `.env` cùng thư mục, Compose tự đọc và thay vào các chỗ `${TEN_BIEN}`:
```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:?hay dat DB_ROOT_PASSWORD trong .env}
```
```sh
# .env  (nhớ thêm .env vào .gitignore, không commit lên git)
DB_ROOT_PASSWORD=mot_mat_khau_manh
```
`${BIEN:-mac_dinh}` dùng giá trị mặc định nếu chưa đặt, `${BIEN:?thong_bao}` báo lỗi nếu thiếu.

## Compose Watch (phát triển nhanh)
Từ Compose 2.22 có thể để Compose tự cập nhật container khi sửa code:
```yaml
services:
  web:
    build: .
    develop:
      watch:
        - action: sync        # chép file thay đổi vào container
          path: ./src
          target: /app/src
        - action: rebuild     # đổi file này thì build lại image
          path: package.json
```
```sh
docker compose watch
```

# References
- https://viblo.asia/euclid/posts/DXOkRZYwkdZ
- https://docs.docker.com/compose/wordpress/#define-the-project
- https://docs.docker.com/compose/ (tài liệu chính thức, mục Compose Specification)
