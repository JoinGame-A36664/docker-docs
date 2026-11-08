# 9. Cài đặt các package phổ biến trên Alpine

____
____

# <a name="content">Nội dung</a>

![https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg](https://nickjanetakis.com/assets/blog/cards/docker-tips-and-tricks-56b5452dc709c8861641d9011d55ed5e6f5138b7d1e76a5e258160077c903076.jpg)

- Alpine là một bản phân phối Linux nhẹ. Hãy cùng tìm hiểu cách cài đặt một vài gói thường thấy trong các ứng dụng web.

- Nếu bạn đã sử dụng Debian, Ubuntu, CentOS hoặc phân phối khác trong một thời gian dài, thì rất có thể bạn đã quen thuộc với những gói ứng dụng của bạn cần và cách cài đặt chúng.

- **Dưới đây là thống kê các package manager của các OS**

    | DISTRIBUTION | PACKAGE MANAGER COMMAND |
    | ------------- | ------------- |
    | Alpine | apk |
    | Arch | pacman |
    | Debian / Ubuntu | apt |
    | CentOS / RHEL (CentOS 7 đã hết hỗ trợ; dùng Rocky/Alma) | yum (nay là dnf) |
    | Fedora | dnf |
    

- Để quản lý các package với Alpine, bạn sẽ phải chạy các lệnh `apk`. Dưới đây là danh sách các package phổ biến mà bạn có thể sẽ cài đặt cho các ứng dụng web khác nhau. Tôi đã đưa vào Debian/ Ubuntu để tham khảo dễ dàng.

    | Mục đích | ALPINE | DEBIAN / UBUNTU |
    | ------------- | ------------- |
    | Connecting to PostgreSQL | postgresql-dev | libpq-dev |
    |Connecting to MySQL / MariaDB | mariadb-dev | libmysqlclient-dev |
    |Interacting with Imagemagick | imagemagick-dev | imagemagick |
    |Dealing with bcrypt | libffi-dev | libffi-dev |

- Bên trên là các gói mà tôi sẽ cài đặt một lần trong một thời gian nào đó cho các ứng dụng web khác nhau. Để cài đặt một trong số chúng, bạn sẽ chạy câu lệnh:

        apk add package_name

- Tôi đã có rất nhiều may mắn chỉ với Google cho "libpq-dev for Alpine" (và tương tự), do đó bạn có thể sử dụng chiến thuật đó khi tìm kiếm tên gói của Alpine khi bạn biết chúng đang có ở phân phối khác.

- Ngoài ra, nếu bạn gặp lỗi "unsatisfiable constraints", điều đó thường có nghĩa là gói mà bạn đang cố gắng cài đặt không tồn tại.

> **Bổ sung (2026):** trong Dockerfile trên Alpine hãy dùng `apk add --no-cache <goi>`: cờ `--no-cache` bỏ qua việc lưu bộ nhớ đệm chỉ mục gói nên image nhỏ hơn và không cần `rm -rf /var/lib/apt/lists/*` như Debian/Ubuntu. Gói build tạm thời có thể cài thành nhóm rồi gỡ: `apk add --no-cache --virtual .build-deps gcc musl-dev && ... && apk del .build-deps`. Ngoài ra Alpine dùng `musl` thay cho `glibc` nên một số gói nhị phân dựng sẵn (ví dụ wheel Python) có thể phải biên dịch lại, nếu gặp rắc rối hãy thử bản `-slim` (Debian) của image.

____

# <a name="content-others">Các nội dung khác</a>
