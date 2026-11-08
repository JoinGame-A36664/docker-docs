# Từ điển dễ hiểu

Bạn không cần nhớ hết. Khi gặp từ lạ trong bài, quay lại đây. Hình dung chung: **Docker giống một xưởng làm nhà lắp ghép**.

| Từ | Nghĩa đơn giản | Ví dụ đời thường |
|---|---|---|
| **Image** (ảnh, bản mẫu) | Một gói chứa sẵn **chương trình cùng mọi thứ nó cần để chạy**. Chỉ để xem và sao chép, không tự chạy. | Bản thiết kế + vật liệu của một căn nhà lắp ghép, đóng sẵn trong thùng |
| **Container** (hộp chạy) | Một bản **đang chạy** được tạo ra từ image. Từ một image làm được nhiều container. | Căn nhà thật được dựng lên từ cái thùng đó. Dựng 3 căn giống nhau cũng được |
| **Dockerfile** | File chữ ghi **các bước làm ra một image**, từ trên xuống dưới. | Công thức nấu ăn, hoặc sách hướng dẫn lắp ráp |
| **Build** (đóng gói) | Chạy Dockerfile để tạo ra image. | Làm theo công thức để ra món |
| **Registry / Docker Hub** | Nơi lưu và chia sẻ image trên mạng. | Cửa hàng ứng dụng, hoặc thư viện cho mượn bản thiết kế |
| **Pull / Push** | Tải image về / đưa image lên registry. | Tải ứng dụng về / đăng ứng dụng lên |
| **Tag** (nhãn phiên bản) | Chữ gắn sau tên image để phân biệt phiên bản, ví dụ `redis:7-alpine`. | Số phiên bản của phần mềm |
| **Port** (cổng) | "Cửa" để nói chuyện với một chương trình, ghi bằng con số. Web thường dùng cổng 80. | Số phòng trong một tòa nhà |
| **Publish port** (mở cổng ra ngoài, `-p 8080:80`) | Nối **cổng của máy bạn** với **cổng bên trong container**. Không nối thì bên ngoài không vào được. | Làm một cửa thông từ phòng bên trong ra hành lang |
| **Volume** (ổ lưu dữ liệu) | Nơi lưu dữ liệu nằm **bên ngoài** container, nên container bị xóa dữ liệu vẫn còn. | Cái ngăn kéo để ngoài sân: nhà bị phá, đồ trong ngăn kéo vẫn còn |
| **Bind mount** (gắn thư mục) | Gắn thẳng một thư mục trên máy bạn vào container. Sửa file ở máy là container thấy ngay. | Một cánh cửa sổ nhìn thẳng sang thư mục của bạn |
| **Network** (mạng riêng) | Mạng nội bộ do Docker tạo ra để các container **nói chuyện với nhau bằng tên**. | Hệ thống điện thoại nội bộ: gọi "bếp" thay vì nhớ số máy |
| **Compose** | Công cụ cho phép viết **cả hệ thống nhiều container trong một file**, rồi bật tắt bằng một lệnh. | Kế hoạch chung của cả công trình, thay vì dặn thợ từng việc |
| **Service** (dịch vụ) | Một phần của hệ thống trong file Compose, ví dụ "web", "cơ sở dữ liệu". | Một bộ phận: bếp, kho, lễ tân |
| **YAML** | Kiểu viết file cấu hình bằng chữ, **thụt lề để thể hiện cái nào nằm trong cái nào**. | Dàn ý có gạch đầu dòng, thụt vào là ý con |
| **Healthcheck** (kiểm tra sức khỏe) | Docker tự hỏi ứng dụng "bạn còn ổn không?" theo định kỳ. | Y tá đi đo nhiệt độ từng phòng |
| **Environment variable** (biến môi trường) | Giá trị cấu hình truyền cho chương trình từ bên ngoài, ví dụ địa chỉ cơ sở dữ liệu. | Tờ giấy dặn việc dán ngoài cửa phòng |
| **Secret** (bí mật) | Thông tin nhạy cảm như mật khẩu, được đưa cho container một cách kín đáo. | Chìa khóa giao riêng, không dán lên cửa |
| **Reverse proxy** (nginx đứng trước) | Một chương trình đứng ở cửa, nhận mọi yêu cầu từ ngoài rồi chuyển vào đúng nơi bên trong. | Lễ tân: khách chỉ gặp lễ tân, lễ tân dẫn đến đúng phòng |
| **Log** (nhật ký) | Dòng chữ chương trình ghi lại những gì nó đang làm hoặc lỗi gặp phải. | Sổ ghi chép của người trực |
| **Cơ sở dữ liệu** (database) | Nơi lưu dữ liệu lâu dài của ứng dụng (người dùng, bài viết...). | Kho lưu trữ hồ sơ |
| **Sao lưu** (backup) | Chép dữ liệu ra một nơi khác để lỡ mất còn khôi phục lại. | Photo giấy tờ quan trọng cất riêng |
| **CI** | Hệ thống tự động đóng gói và kiểm tra mỗi khi bạn đẩy code lên. | Dây chuyền kiểm hàng tự động |

## Ba câu để nhớ
1. **Image là khuôn, container là cái được đúc ra từ khuôn.** Xóa container không mất khuôn.
2. **Container là thứ tạm thời.** Xóa đi làm lại bất cứ lúc nào. Cái cần giữ lâu thì để vào **volume**.
3. **Muốn container nói chuyện với nhau thì cho vào cùng một mạng**, rồi gọi bằng tên.
