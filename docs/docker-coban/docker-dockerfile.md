# 1. Ghi chép về Dockerfile

> **Cập nhật (2026):** các thay đổi lớn so với bản gốc, đã được sửa trực tiếp trong bài hoặc ghi chú ở từng mục:
> - Docker build mặc định dùng **BuildKit** (nhanh hơn, cache tốt hơn, build song song). Lệnh `docker build` vẫn giữ nguyên cách dùng; thêm `docker buildx build` khi cần build đa nền tảng.
> - `MAINTAINER` đã **deprecated**, dùng `LABEL maintainer="..."`.
> - `ENV key value` (không có dấu `=`) là cú pháp cũ, nên viết `ENV key=value`.
> - File loại trừ khi build tên là **`.dockerignore`** (bản gốc ghi nhầm `.dockerfileignore`).
> - Các ví dụ dùng `ubuntu:14.04` đã đổi sang `ubuntu:24.04`; ví dụ nào cần ghim phiên bản thì ghi rõ tag.
> - Cuối bài có thêm các mục: `HEALTHCHECK`, multi-stage build, `docker init`, và danh sách thực hành tốt khi viết Dockerfile.
- Dockerfile có thể hình dung như một script dùng để build các image trong container.
- Dockerfile bao gồm các câu lệnh liên tiếp nhau được thực hiện tự động trên một image gốc để tạo ra một image mới. Dockerfile giúp đơn giản hóa tiến trình từ lúc bắt đầu đến khi kết thúc.
- Trong `Dockerfile` có các câu lệnh chính sau:
```sh
FROM
RUN
CMD
....còn nữa
```

# 2. Dockerfile Systax

```sh
# Comment
INSTRUCTION arguments
```
- Các INSTRUCTION là các chỉ thị, được docker quy định. Khi khai báo, các bạn phải viết chữ in hoa.
- Các arguments là đoạn nội dung mà chỉ thị sẽ làm gì.
- Ví dụ:
```sh
# Comment
RUN echo 'we are running some # of cool things'
```
- Chúng ta sẽ đi tìm hiểu các INSTRUCTION

# 3. Dockerfile Commands
## 3.1 FROM
- Dùng để chỉ ra image được build từ đâu (từ image gốc nào)
```sh
FROM ubuntu

hoặc có thể chỉ rõ tag của image gốc

FROM ubuntu:24.04
```
- Bản gốc viết `FROM ubuntu14.04:lastest`, sai cú pháp (đúng là `ubuntu:14.04`, và `latest` chứ không phải `lastest`). Ubuntu 14.04 đã hết hỗ trợ nên đổi sang `24.04`.
- **Nên chỉ rõ tag**, tránh dùng `latest` (hôm nay build một đằng, tuần sau build một nẻo). Với môi trường cần kiểm soát chặt có thể ghim cả digest: `FROM ubuntu:24.04@sha256:...`.
- Thường chọn biến thể nhỏ: `alpine`, `slim` hoặc `distroless` để image nhẹ và ít lỗ hổng hơn.
- Có thể đặt tên giai đoạn build bằng `FROM ... AS ten` (dùng cho multi-stage build, xem cuối bài).

## 3.2 RUN
- Dùng để chạy một lệnh nào đó khi build image, ví dụ về một `Dockerfile`
```sh
FROM ubuntu
RUN apt-get update
RUN apt-get install curl -y
```

- Mỗi lệnh `RUN` tạo thêm một **layer** mới. Cách viết trên có hai nhược điểm: tạo nhiều layer, và nếu layer `apt-get update` bị cache cũ thì `apt-get install` ở lần build sau có thể lấy danh sách gói đã lỗi thời. Nên **gộp lại** và dọn cache trong cùng một lệnh:
```sh
FROM ubuntu:24.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```


## 3.3 CMD
- Lệnh CMD dùng để truyền một lệnh của Linux mỗi khi thực hiện khởi tạo một container từ image (image này được build từ `Dockerfile`)
- Có các cách (trong docs nói có 3 cách) sử dụng lệnh CMD, ví dụ 
```sh 
#Cách 1
FROM ubuntu
RUN apt-get update
RUN apt-get install curl -y
CMD ["curl", "ipinfo.io"]
```
hoặc
```sh 
#Cách 2
FROM ubuntu
RUN apt-get update
RUN apt-get install wget -y
CMD curl ifconfig.io
```

## 3.4 LABEL
```sh
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```
Chỉ thị **LABEL** dùng để add các metadata vào image.

- Ví dụ: 
```sh
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL version="1.0"
LABEL description="This text illustrates \
that label-values can span multiple lines."
```

- Để xem các **label** của images, dùng lệnh `docker inspect`.
```sh
  "Labels": {
      "com.example.vendor": "ACME Incorporated"
      "com.example.label-with-value": "foo",
      "version": "1.0",
      "description": "This text illustrates that label-values can span multiple lines.",
      "multi.label1": "value1",
      "multi.label2": "value2",
      "other": "value3"
  },
```

## 3.5 MAINTAINER
```sh
MAINTAINER <name>
```
Dùng để đặt tên giả của images.

> **Cập nhật (2026):** `MAINTAINER` đã bị **deprecated**, không nên dùng nữa. Hãy dùng `LABEL`, có thể dùng chuẩn nhãn OCI:

Hoặc bạn có thể sử dụng
```sh
LABEL maintainer="SvenDowideit@home.org.au"
LABEL org.opencontainers.image.authors="SvenDowideit@home.org.au"
```

## 3.6 EXPOSE
```sh
EXPOSE <port> [<port>...]
```
- Lệnh EXPOSE thông báo cho Docker rằng image sẽ lắng nghe trên các cổng được chỉ định khi chạy. Lưu ý là cái này chỉ 
để khai báo, chứ ko có chức năng nat port từ máy host vào container. Muốn nat port, thì phải sử dụng cờ -p (nat một vài port) hoặc -P (nat tất
cả các port được khai báo trong EXPOSE) trong quá trình khởi tạo contrainer.

## 3.7 ENV
```sh
ENV <key> <value>        # cú pháp cũ, nên tránh
ENV <key>=<value> ...
```
- Khai báo cáo biến giá trị môi trường. Khi run container từ image, các biến môi trường này vẫn có hiệu lực.

- Biến môi trường có thể được sử dụng trong các chỉ dẫn lệnh sau:

  - ADD
  - COPY
  - ENV
  - EXPOSE
  - FROM
  - LABEL
  - STOPSIGNAL
  - USER
  - VOLUME
  - WORKDIR

- Ta có thể sử dụng các khai báo trong file `.dockerignore` (bản gốc ghi nhầm là `.dockerfileignore`) để phớt lờ đi sự có mặt của các file đang có trong đường dẫn thực hiện build Docker. `.dockerignore` đặt cùng chỗ với thư mục build context và sử dụng `filepath.Match rules`. Nên loại trừ `.git`, `node_modules`, file `.env`, thư mục build tạm... để build nhanh hơn và không vô tình đưa bí mật vào image. Ví dụ:

  */temp* có nghĩa là loại trừ các file và đường dẫn bắt đầu bằng temp hoặc sub-directory của root. Ví dụ sau đều có thể hiểu là một:

      - /subdir/temp

  hoặc 

      - /sbdir/temp.dump

  các file hoặc đường dẫn xuất hiện cụm từ `temp` đều được ignore.

        pattern:
        { term }

    term:

        '*'         matches any sequence of non-Separator characters
        '?'         matches any single non-Separator character
        '[' [ '^' ] { character-range } ']'
                    character class (must be non-empty)
        c           matches character c (c != '*', '?', '\\', '[')
        '\\' c      matches character c

    character-range:
    
        c           matches character c (c != '\\', '-', ']')
        '\\' c      matches character c
        lo '-' hi   matches character c for lo <= c <= hi

  dòng bắt đầu bằng ! có thể hiểu là tạo ra một ngoại lệ trong file. Ví dụ:

        *.md
        !README.md
    
  có thể hiểu là tất cả các file .md `đều không được sử dụng ngoại trừ file README.md`

## 3.8 ADD
```sh
ADD has two forms:
ADD <src>... <dest>
ADD ["<src>",... "<dest>"] (this form is required for paths containing whitespace)
```
- Chỉ thị ADD copy file, thư mục, remote files URL (src) và thêm chúng vào filesystem của image (dest)
- **src**: có thể khai báo nhiều file, thư mục, có thể sử dụng các ký hiệu như *,?,...
- **dest** phải là đường dẫn tuyệt đối hoặc có quan hệ với chỉ thị **WORKDIR**

Note: If your URL files are protected using authentication, you will need to use RUN wget, RUN curl or use another tool from within the container as the ADD instruction does not support authentication.

> **Cập nhật (2026):** khuyến nghị chính thức là **ưu tiên `COPY`**. Chỉ dùng `ADD` khi cần tự giải nén file `.tar` cục bộ. Với file từ URL, nên dùng `RUN curl ... ` kèm kiểm tra checksum hoặc dạng `ADD --checksum=sha256:... <url> <dest>`. Xem thêm bài tip [ADD với COPY](../docker-tips/docker-dockerfile-add-with-copy.md).

- Các quy định:
  - The <src> path must be inside the context of the build: Có nghĩa là <src> phải nằm trong thư mục đang build (chứa dockerfiles).
  - If <src> is a directory, the entire contents of the directory are copied, including filesystem metadata. The directory itself is not copied, just its contents.
  - If multiple <src> resources are specified, either directly or due to the use of a wildcard, then <dest> must be a directory, and it must end with a slash /.
  - If <dest> does not end with a trailing slash, it will be considered a regular file and the contents of <src> will be written at <dest>.
  - If <dest> doesn’t exist, it is created along with all missing directories in its path.

## 3.9 COPY
```sh
COPY <src>... <dest>
COPY ["<src>",... "<dest>"] (this form is required for paths containing whitespace)
```
- Chỉ thị COPY, copy file, thư mục (src) và thêm chúng vào filesystem của container (dest).
- Các lưu ý tương tự chỉ thị ADD.
- Tùy chọn hay dùng: `COPY --chown=user:group src dest` (gán chủ sở hữu ngay lúc copy, đỡ một lệnh `RUN chown`) và `COPY --from=ten_stage src dest` (lấy file từ một giai đoạn build khác, xem multi-stage ở cuối bài).
- Mẹo tối ưu cache: copy file khai báo thư viện (`package.json`, `requirements.txt`...) và cài thư viện **trước**, rồi mới copy phần code. Code đổi liên tục nhưng thư viện ít đổi, nhờ vậy Docker dùng lại layer cache của bước cài thư viện.

## 3.10 ENTRYPOINT
```sh
ENTRYPOINT ["executable", "param1", "param2"] (exec form, preferred)
ENTRYPOINT command param1 param2 (shell form)
```

Hai cái CMD và ENTRYPOINT có tác dụng tương tự nhau. Nếu một Dockerfile có cả CMD và ENTRYPOINT thì CMD sẽ thành param cho script ENTRYPOINT.
Lý do người ta dùng ENTRYPOINT nhằm chuẩn bị các điều kiện setup như tạo user, mkdir, change owner... cần thiết để chạy service trong container.

Bảng so sánh ngắn (bổ sung 2026):

| | CMD | ENTRYPOINT |
|---|---|---|
| Vai trò | Lệnh / tham số **mặc định** | "Chương trình chính" của container |
| Bị ghi đè khi `docker run image <lệnh>` | Có, bị thay hoàn toàn | Không (lệnh bạn gõ trở thành tham số của ENTRYPOINT) |
| Muốn ghi đè | Gõ lệnh sau tên image | `docker run --entrypoint ...` |

- Luôn dùng **dạng exec** (mảng JSON) `["nginx", "-g", "daemon off;"]` thay vì dạng shell `nginx -g "daemon off;"`. Dạng shell chạy qua `/bin/sh -c`, tiến trình của bạn không phải PID 1 nên không nhận tín hiệu `SIGTERM` khi `docker stop`, dẫn tới container phải đợi 10 giây rồi bị kill.
- Mẫu hay dùng: `ENTRYPOINT ["python", "app.py"]` kèm `CMD ["--port", "8000"]` để người dùng đổi tham số dễ dàng.


## 3.11 VOLUME
```sh
VOLUME ["/data"]
```
- mount thư mục từ máy host và container. Tương tự `option -v` khi tạo container.
- Lưu ý chính xác hơn (bổ sung 2026): `VOLUME` trong Dockerfile chỉ **đánh dấu** thư mục đó chứa dữ liệu cần lưu. Khi chạy container, nếu bạn không tự mount gì thì Docker tạo một **anonymous volume** (tên là chuỗi hex dài) ở `/var/lib/docker/volumes/`, không phải gắn thư mục có sẵn của host. Muốn chọn chỗ lưu thì dùng `-v ten_volume:/data` (named volume) hoặc `-v /duong/dan/host:/data` (bind mount) khi `docker run`.
- Thư mục chưa volumes là `/var/lib/docker/volumes/`. Ứng với mỗi container sẽ có các thư mục con nằm trong thư mục này. Tìm thư mục chưa Volumes của container `sad_euclid`: 
```sh
root@adk:/var/lib/docker/volumes# docker inspect sad_euclid | grep /var/lib/docker/volumes
"Source": "/var/lib/docker/volumes/491a2a775a4cf02bbaca105ec25995008cc7adbc5511e054bb9c6a691a2681ee/_data",
```


## 3.12 USER
```sh
USER daemon
```
- Set username hoặc UID để chạy các lệnh RUN, CMD, ENTRYPOINT trong dockerfiles.
- Mặc định container chạy bằng `root`. Thực hành tốt là tạo user thường rồi chuyển sang dùng nó để giảm thiệt hại nếu ứng dụng bị khai thác:
```sh
RUN groupadd --system app && useradd --system --gid app --create-home app
USER app
```
(Trên Alpine dùng `addgroup -S app && adduser -S -G app app`.)

## 3.13 WORKDIR
```sh
WORKDIR /path/to/workdir
```
- Chỉ thị WORKDIR dùng để đặt thư mục đang làm việc cho các chỉ thị khác như: RUN, CMD, ENTRYPOINT, COPY, ADD,...

## 3.14 ARG
```sh
ARG <name>[=<default value>]
```
- Chỉ thị ARG dùng để định nghĩa các giá trị của biến được dùng trong quá trình build image (lệnh `docker build` --build-arg <varname>=<value>). 
- biến ARG sẽ không bền vững như khi sử dụng ENV.
- `ARG` đặt **trước** `FROM` dùng được để chọn image gốc: `ARG PYTHON_VERSION=3.12` rồi `FROM python:${PYTHON_VERSION}-slim`.
- Không dùng `ARG` hay `ENV` để truyền mật khẩu / token vào image, vì chúng lưu lại trong lịch sử layer (`docker history`). Dùng build secret của BuildKit (xem mục thực hành tốt bên dưới).

## 3.15 STOPSIGNAL
```sh
STOPSIGNAL signal
```
- Gửi tín hiệu để container tắt đúng cách.

## 3.16 SHELL
```sh
SHELL ["executable", "parameters"]
```

- Chỉ thị Shell cho phép các shell form khác có thể ghi đè shell mặc định.
- Mặc định trên Linux là `["/bin/sh", "-c"]` và Windows là `["cmd", "/S", "/C"]`.

Ví dụ:
```sh
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Executed as cmd /S /C echo default
RUN echo default

# Executed as cmd /S /C powershell -command Write-Host default
RUN powershell -command Write-Host default

# Executed as powershell -command Write-Host hello
SHELL ["powershell", "-command"]
RUN Write-Host hello

# Executed as cmd /S /C echo hello
SHELL ["cmd", "/S"", "/C"]
RUN echo hello
```

## 3.17 ONBUILD
```sh
ONBUILD [INSTRUCTION]
```

- Chỉ thị ONBUILD được khai báo trong base image. Và khi child image build image từ  base image thì lệnh ONBUILD mới được thực thi.
- Ví dụ: http://container42.com/2014/02/06/docker-quicktip-3-onbuild/

## 3.18 HEALTHCHECK
```sh
HEALTHCHECK [OPTIONS] CMD command
HEALTHCHECK NONE
```
- Cho Docker biết cách kiểm tra container có thực sự đang hoạt động, hay chỉ là tiến trình còn sống nhưng ứng dụng đã treo.
- Ví dụ:
```sh
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```
- Container có thêm trạng thái `healthy` / `unhealthy`, xem ở cột `STATUS` của `docker ps`. Compose (`depends_on: condition: service_healthy`) và Swarm dùng trạng thái này để quyết định chạy service tiếp theo hoặc thay container hỏng.
- Image tối giản (distroless, scratch) có thể không có `curl`; khi đó dùng chương trình có sẵn của ứng dụng để tự kiểm tra.

## 3.19 Multi-stage build (build nhiều giai đoạn)
- Vấn đề: để biên dịch ứng dụng cần compiler, SDK, thư viện dev khá nặng; nhưng để **chạy** thì không cần. Nếu build tất cả trong một giai đoạn, image cuối rất nặng và chứa nhiều thứ không cần thiết.
- Giải pháp: dùng nhiều `FROM` trong một Dockerfile. Giai đoạn đầu build, giai đoạn cuối chỉ copy kết quả sang image nhỏ gọn.
- Ví dụ (ứng dụng Go):
```sh
# Giai đoạn 1: build
FROM golang:1.23 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/server ./cmd/server

# Giai đoạn 2: chạy
FROM gcr.io/distroless/static-debian12
COPY --from=build /out/server /server
USER nonroot
ENTRYPOINT ["/server"]
```
- Ví dụ (ứng dụng Node.js: build frontend rồi chạy bằng nginx):
```sh
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
```
- Chỉ build tới một giai đoạn nhất định (hữu ích khi debug): `docker build --target build -t myapp:build .`
- (Bài tip [Dockerfile multi](../docker-tips/docker-dockerfile-multi.md) trong repo nói về cách tổ chức **nhiều Dockerfile** cho nhiều dịch vụ, không phải multi-stage build.)

## 3.20 BuildKit và buildx
- **BuildKit** là bộ máy build mặc định của Docker hiện nay (từ Docker 23.0). Nhờ nó, các giai đoạn độc lập được build song song và cache hiệu quả hơn nhiều.
- `docker buildx build` là lệnh build "đầy đủ tính năng" của BuildKit. Một số khả năng đáng dùng:
```sh
# Build cho nhiều kiến trúc CPU cùng lúc (amd64 cho server, arm64 cho Apple Silicon/Raspberry Pi), rồi đẩy lên registry
docker buildx build --platform linux/amd64,linux/arm64 -t user/myapp:1.0 --push .

# Xem quá trình build chi tiết, không cắt bớt
docker build --progress=plain -t myapp .
```
- **Cache mount**: giữ cache của trình quản lý gói giữa các lần build mà không làm phình image:
```sh
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```
- **Secret mount**: dùng token/mật khẩu trong lúc build mà không để lại trong image:
```sh
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm ci
```
```sh
docker build --secret id=npm_token,src=$HOME/.npm_token -t myapp .
```

## 3.21 `docker init` (tạo sẵn Dockerfile và compose)
- Từ Docker Desktop 4.18 / Docker CLI mới, lệnh `docker init` đọc thư mục dự án (Node, Python, Go, Java, Rust, ASP.NET...) rồi sinh sẵn `Dockerfile`, `.dockerignore` và `compose.yaml` theo thực hành tốt. Rất tiện để có bản nháp ban đầu, nhưng vẫn nên đọc và hiểu từng dòng:
```sh
cd my-project
docker init
```

## 3.22 Tổng hợp thực hành tốt khi viết Dockerfile (bổ sung 2026)
1. Chọn image gốc nhỏ và **chỉ rõ tag** (`python:3.12-slim`, không dùng `latest`).
2. Đặt các bước ít thay đổi (cài thư viện) lên trước, bước hay thay đổi (copy code) xuống sau để tận dụng cache.
3. Gộp các lệnh `apt-get update && apt-get install` trong một `RUN` và dọn cache.
4. Luôn có `.dockerignore`.
5. Dùng multi-stage build để image cuối không chứa công cụ build.
6. Không chạy bằng `root`: dùng `USER`.
7. Dùng dạng **exec** cho `CMD` / `ENTRYPOINT`.
8. Không đưa bí mật vào image (`ENV`, `ARG`, `COPY .env`). Dùng secret mount lúc build, biến môi trường hoặc `secrets` lúc chạy.
9. Thêm `HEALTHCHECK` cho service chạy lâu dài.
10. Quét lỗ hổng cho image trước khi triển khai, ví dụ `docker scout quickview myapp:1.0` hoặc công cụ như Trivy.
11. Dùng công cụ lint như [hadolint](https://github.com/hadolint/hadolint) để phát hiện lỗi thường gặp.
