# Dự án thực hành giai đoạn đầu: Sổ lưu bút Docker

Dự án nhỏ để bạn **tự tay** đi qua các khái niệm cơ bản của tài liệu này: container, image, Dockerfile, network, volume, healthcheck và Docker Compose. Mỗi bước bổ sung đúng một khái niệm mới, và bước sau giải quyết vấn đề mà bước trước để lộ ra.

Ứng dụng là một trang web Flask (Python) đếm số lượt truy cập và lưu các lời nhắn vào Redis. Cuối cùng bạn sẽ có mô hình 3 container:

```
trình duyệt ──► nginx (:8080) ──► web (Flask + gunicorn) ──► redis
                  mạng "frontend"        mạng "backend"      (volume redis_data)
```

Thời gian: khoảng 1 đến 2 giờ. Không cần biết Python, bạn không phải sửa code để làm các bước 1 đến 7.

## Chuẩn bị
- Đã cài Docker theo bài [Cài đặt docker](../docs/docker-5m/01.Caidatdocker.md) (Linux) hoặc [Hướng dẫn cài đặt Docker](../docs/docker-coban/docker-thuchanh-caidat.md) (Docker Desktop cho Windows / macOS).
- Kiểm tra:
  ```sh
  docker --version
  docker compose version
  ```
- Mở terminal tại thư mục `practice/` này. Các lệnh dưới đây dùng cú pháp bash; trên **PowerShell** chỉ khác chỗ ghi rõ.

## Cấu trúc thư mục
```
practice/
├── README.md            ← bài này
├── site/index.html      ← trang tĩnh cho bước 1
├── app/
│   ├── app.py           ← ứng dụng Flask
│   ├── requirements.txt ← thư viện Python (đã ghim phiên bản)
│   ├── Dockerfile       ← bước 2
│   └── .dockerignore
├── nginx/default.conf   ← cấu hình reverse proxy cho bước 5
├── compose.yaml         ← bước 4 trở đi
├── .env.example         ← mẫu biến môi trường
└── .gitignore
```

---

## Bước 1. Chạy container đầu tiên và gắn thư mục vào container
**Mục tiêu:** hiểu `docker run`, `-p` (publish port), `-v` (bind mount), và vòng đời container.

```sh
docker run -d --name site -p 8080:80 -v "$(pwd)/site:/usr/share/nginx/html:ro" nginx:1.27-alpine
```
PowerShell: thay `$(pwd)` bằng `${PWD}`:
```powershell
docker run -d --name site -p 8080:80 -v "${PWD}/site:/usr/share/nginx/html:ro" nginx:1.27-alpine
```

- Mở `http://localhost:8080`, bạn thấy trang "Xin chào từ container nginx!".
- Mở `site/index.html`, sửa vài chữ, lưu lại, tải lại trình duyệt: nội dung đổi ngay mà **không** phải chạy lại container. Đó là bind mount.
- Các lệnh để quan sát: `docker ps`, `docker logs site`, `docker exec -it site sh` (gõ `ls /usr/share/nginx/html` rồi `exit`), `docker inspect site`.

Giải thích: `-d` chạy nền, `--name` đặt tên, `-p 8080:80` nối cổng 8080 của máy bạn tới cổng 80 trong container, `:ro` gắn chỉ đọc.

**Tự kiểm tra**
1. Nếu bỏ `-p 8080:80` thì có truy cập được từ trình duyệt không? Vì sao?
2. Nếu chạy `docker rm -f site` rồi chạy lại lệnh trên, trang có còn nguyên không? Dữ liệu nằm ở đâu?

Dọn: `docker rm -f site`

---

## Bước 2. Viết Dockerfile và build image của riêng bạn
**Mục tiêu:** hiểu image, layer, cache, và những thực hành tốt trong Dockerfile ([bài Dockerfile](../docs/docker-coban/docker-dockerfile.md)).

Mở `app/Dockerfile` và đọc các chú thích, chú ý: image gốc có tag rõ ràng, copy `requirements.txt` trước code để tận dụng cache, chạy bằng user thường, `HEALTHCHECK`, `CMD` dạng exec.

```sh
cd app
docker build -t guestbook-web:1.0 .
docker images guestbook-web
docker history guestbook-web:1.0
```

Thử làm **build lần hai** ngay: lần này gần như tức thì vì mọi layer đã có cache. Giờ thêm một dòng chú thích vào `app/app.py` rồi build lại: chỉ layer `COPY app.py` trở xuống bị build lại, bước `pip install` vẫn dùng cache.

Chạy thử (chưa có Redis):
```sh
docker run -d --name web -p 8000:8000 guestbook-web:1.0
```
Mở `http://localhost:8000`: bạn thấy khung lỗi đỏ **"Không kết nối được tới Redis"**, đó là hành vi mong đợi. Ứng dụng này cần một Redis để chạy, và đó là vấn đề bước 3 sẽ giải quyết.

Quan sát thêm:
```sh
docker logs web
docker ps          # sau khoảng 15 đến 20 giây cột STATUS có (healthy)
```
Cột `(healthy)` do `HEALTHCHECK` trong Dockerfile gọi `/health` của ứng dụng. Trang `/health` luôn trả 200 khi tiến trình web còn sống, kể cả khi Redis chưa có.

**Tự kiểm tra**
1. Vì sao `COPY requirements.txt` đứng trước `COPY app.py`?
2. `docker history` cho thấy layer nào lớn nhất? Vì sao?

Dọn: `docker rm -f web` rồi `cd ..`

---

## Bước 3. Cho hai container nói chuyện với nhau: network và volume bằng tay
**Mục tiêu:** hiểu user-defined network (gọi nhau bằng **tên**), biến môi trường, và vì sao cần volume ([bài Network](../docs/docker-coban/docker-network.md), [bài Volume](../docs/docker-coban/docker-volume.md)).

```sh
docker network create guestbook-net

docker run -d --name redis --network guestbook-net redis:7-alpine

docker run -d --name web --network guestbook-net -e REDIS_HOST=redis -p 8000:8000 guestbook-web:1.0
```
Mở `http://localhost:8000`: bộ đếm hoạt động, gửi vài lời nhắn thử. Ứng dụng tìm Redis qua tên `redis`, Docker DNS đổi tên đó ra IP (không cần `--link`).

Thí nghiệm "mất dữ liệu":
```sh
docker rm -f redis
docker run -d --name redis --network guestbook-net redis:7-alpine
```
Tải lại trang: bộ đếm và lời nhắn **biến mất**, vì dữ liệu nằm trong lớp ghi của container đã bị xóa. Giờ làm lại với volume:
```sh
docker rm -f redis
docker run -d --name redis --network guestbook-net -v redis_data:/data redis:7-alpine redis-server --appendonly yes
```
Gửi vài lời nhắn, rồi `docker rm -f redis` và chạy lại đúng lệnh trên: dữ liệu còn nguyên. (Kiểm tra volume: `docker volume ls`.)

**Tự kiểm tra**
1. Điều gì xảy ra nếu chạy container `web` **không** có `--network guestbook-net`?
2. `-v redis_data:/data` khác `-v ./thu-muc:/data` ở điểm nào?

Gõ đến đây là bạn đã phải nhớ 3 lệnh dài. Bước 4 giải quyết chuyện đó. Dọn:
```sh
docker rm -f web redis
docker network rm guestbook-net
docker volume rm redis_data
```

---

## Bước 4. Gom lại bằng Docker Compose
**Mục tiêu:** mô tả cả hệ thống trong **một file**, chạy bằng **một lệnh** ([bài Docker Compose](../docs/docker-coban/docker-compose.md)).

Mở `compose.yaml`, đọc chú thích, đối chiếu từng phần với các lệnh `docker run` ở bước 3 (`environment` ↔ `-e`, `volumes` ↔ `-v`, `networks` ↔ `--network`).

```sh
cp .env.example .env            # PowerShell: Copy-Item .env.example .env
docker compose config           # in file cuối cùng sau khi thay biến, dùng để kiểm tra lỗi
docker compose up -d --build
docker compose ps
```
Mở `http://localhost:8080` (qua nginx). Chờ vài giây cho đến khi `docker compose ps` hiện `healthy` ở `redis` và `web`.

Lưu ý hai điểm trong file:
- `depends_on` với `condition: service_healthy`: web chờ Redis sẵn sàng, nginx chờ web khỏe. Đây là lý do cần `healthcheck`.
- Chỉ `nginx` có `ports:`. `web` và `redis` không mở cổng ra máy bạn: thử `http://localhost:8000` sẽ không vào được.

**Tự kiểm tra**
1. Muốn đổi cổng truy cập từ 8080 sang 9090 thì sửa ở đâu?
2. Vì sao không cần `docker network create` như bước 3?

---

## Bước 5. Reverse proxy và cô lập mạng
**Mục tiêu:** hiểu vai trò của nginx phía trước, và cách tách mạng để giảm bề mặt tấn công ([mục bảo mật trong bài Network](../docs/docker-coban/docker-network.md)).

Xem `nginx/default.conf`: nginx chuyển yêu cầu tới `http://web:8000`.

Compose có hai mạng: `frontend` (nginx, web) và `backend` (web, redis). Kiểm chứng:
```sh
# web nằm trong cả hai mạng nên thấy redis:
docker compose exec web python -c "import socket; print(socket.gethostbyname('redis'))"

# nginx chỉ ở frontend nên KHÔNG phân giải được redis (lệnh báo lỗi là đúng):
docker compose exec nginx nslookup redis
```
Mở `http://localhost:8080` vài lần và để ý dòng **"Container phục vụ"**: đó là ID của container `web`.

**Tự kiểm tra**
1. Nếu kẻ tấn công chiếm được container nginx, nó có kết nối thẳng được tới Redis không? Vì sao?
2. Vì sao nên để `redis` không có `ports:`?

---

## Bước 6. Dữ liệu còn hay mất? `down` và `down -v`
**Mục tiêu:** phân biệt vòng đời container và vòng đời dữ liệu.

1. Mở trang, gửi vài lời nhắn, nhớ số lượt truy cập.
2. ```sh
   docker compose down
   docker compose up -d
   ```
   Tải lại trang: dữ liệu **còn** (container bị xóa nhưng volume `redis_data` vẫn còn: `docker volume ls`).
3. ```sh
   docker compose down -v
   docker compose up -d
   ```
   Lần này dữ liệu **mất sạch** vì `-v` xóa luôn volume.

**Tự kiểm tra:** muốn sao lưu dữ liệu Redis trước khi `down -v` thì làm cách nào? Gợi ý: xem mục bổ sung cuối bài [Volume](../docs/docker-coban/docker-volume.md).

---

## Bước 7. Quan sát, gỡ lỗi và phá thử có chủ đích
```sh
docker compose logs -f web          # xem log liên tục (Ctrl+C để thoát)
docker compose exec web sh          # vào trong container web (gõ whoami: kết quả là "app", không phải root)
docker compose top                  # tiến trình trong từng container
docker stats                        # CPU / RAM theo thời gian thực
```
Phá thử:
```sh
docker compose stop redis
```
Tải trang: hiện khung lỗi đỏ và mã 503, nhưng container `web` **không sập**. Thử `curl -s localhost:8080/health` hoặc xem `docker compose ps`.
```sh
docker compose start redis
```
Tải lại trang: ứng dụng tự hồi phục, dữ liệu còn nguyên.

Vòng lặp phát triển nhanh với Compose Watch (cần Compose 2.23 trở lên, kiểm tra bằng `docker compose version`):
```sh
docker compose watch
```
Mở `app/app.py`, đổi tiêu đề mặc định hoặc thêm chữ vào trang rồi lưu: Compose tự chép file vào container và khởi động lại `web`. Sửa `app/requirements.txt` thì Compose tự build lại image. Nhấn `Ctrl+C` để thoát.

---

## Bước 8. Dọn dẹp
```sh
docker compose down -v --rmi local     # xóa container, mạng, volume và image tự build
docker system df                       # xem Docker còn chiếm bao nhiêu dung lượng
docker image prune                     # xóa image dangling (không còn tag)
```

---

## Bài tập mở rộng (tự làm)
1. **Đổi cổng và tiêu đề** chỉ bằng file `.env`, không sửa `compose.yaml`.
2. **Thêm `restart` và giới hạn tài nguyên**: thêm `deploy.resources.limits` (cpus `0.5`, memory `128M`) cho `web`, kiểm tra bằng `docker stats`. (Xem mục `deploy` trong [bài viết Compose file](../docs/docker-coban/docker-dockercompose.md).)
3. **Đổi Redis sang PostgreSQL**: thêm service `db` (`postgres:16`) kèm `healthcheck` `pg_isready` và `POSTGRES_PASSWORD_FILE` dùng `secrets`; sửa `app.py` dùng `psycopg`. Đây là bài tập gần với thực tế nhất.
4. **Multi-stage build**: tách giai đoạn cài thư viện và giai đoạn chạy, so sánh dung lượng image trước và sau.
5. **Quét lỗ hổng**: `docker scout quickview guestbook-web:1.0` (hoặc dùng Trivy) và thử nâng phiên bản image gốc.
6. **Đẩy image lên registry**: gắn tag `docker tag guestbook-web:1.0 <tai-khoan>/guestbook-web:1.0`, `docker login`, `docker push` (dùng Personal Access Token), rồi chạy lại trên một máy khác.
7. **Chạy trên Kubernetes**: làm theo bài [Kubernetes hiện nay](../docs/docker-nangcao/docker-kubernetes-hien-nay.md), viết Deployment + Service cho `web` và `redis` rồi chạy trên `kind`.

## Gỡ rối thường gặp
| Triệu chứng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| `port is already allocated` / `address already in use` | Cổng 8080 hoặc 8000 đang có chương trình khác dùng | Đổi `HTTP_PORT` trong `.env`, hoặc đổi cổng bên trái dấu `:` ở `-p` |
| `no configuration file provided: not found` | Đang đứng sai thư mục | `cd` vào thư mục có `compose.yaml` (hoặc dùng `docker compose -f practice/compose.yaml ...`) |
| `Cannot connect to the Docker daemon` | Docker chưa chạy | Mở Docker Desktop, hoặc `sudo systemctl start docker` |
| `permission denied ... docker.sock` (Linux) | User chưa trong group `docker` | `sudo usermod -aG docker $USER`, đăng xuất rồi đăng nhập lại |
| Container `web` liên tục khởi động lại | Lỗi trong code / thiếu thư viện | `docker compose logs web` đọc dòng lỗi cuối |
| nginx báo `host not found in upstream "web"` | `web` chưa chạy hoặc không cùng mạng | `docker compose ps`; kiểm tra `networks:` |
| Sửa `app.py` nhưng trang không đổi | Chưa build lại image | `docker compose up -d --build`, hoặc dùng `docker compose watch` |
| Trên Windows: script `.sh` báo `\r: command not found` | File bị đổi xuống dòng CRLF | Repo đã có `.gitattributes` ép LF; chạy `git add --renormalize .` rồi checkout lại |
| Trang trắng / không vào được sau khi `up` | Container chưa kịp `healthy` | Đợi vài giây, xem `docker compose ps` và `docker compose logs` |

## Ghi chú về phạm vi
Dự án dành cho học tập: không có xác thực, không có HTTPS, Redis không đặt mật khẩu và dữ liệu lời nhắn không được lọc nội dung. Đừng đưa nguyên bản này ra Internet. Những việc cần làm khi lên môi trường thật (HTTPS, secrets, backup, giám sát, CI/CD) là bước học tiếp theo.
