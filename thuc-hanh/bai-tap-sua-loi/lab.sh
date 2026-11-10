#!/usr/bin/env bash
# =====================================================================
# BÀI TẬP SỬA LỖI DOCKER
# Phá có kiểm soát một BẢN SAO của hệ thống "Sổ lưu bút" để bạn tự tìm lỗi và sửa.
#
# Cách dùng (trong WSL, đứng ở thư mục này):
#     bash lab.sh giup           xem danh sách lệnh
#     bash lab.sh pha ngau-nhien phá hệ thống bằng một lỗi ngẫu nhiên
#
# AN TOÀN: script chỉ làm việc trong thư mục lab/ (bản sao) và chỉ đụng tới tài nguyên Docker
# mang tên "loi-lab" (dự án Compose "loi-lab", image loi-lab-web, container loi-lab-blocker).
# Nó KHÔNG đụng tới dự án thật của bạn.
# =====================================================================
set -u

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAU="$AQUI/mau"
LAB="${LAB_DIR:-$AQUI/lab}"
DAP_AN="$AQUI/dap-an" 
HIEN_TAI="$LAB/.loi-hien-tai"
MARKER="$LAB/.lab-sua-loi"
PROJ="loi-lab"
PORT=8090
BLOCKER="loi-lab-blocker"
SO_DE=11

# Chế độ chạy thử (không gọi Docker thật), dùng để kiểm tra script: LAB_DRY=1 bash lab.sh pha 3
if [ "${LAB_DRY:-0}" = "1" ]; then
  docker() { echo "[chạy thử, không gọi Docker thật] docker $*"; }
  timeout() { shift; "$@"; }
fi

declare -A MUC_DO=( [1]="Dễ" [2]="Dễ" [3]="Dễ" [4]="Dễ" [5]="Vừa" [6]="Vừa" [7]="Vừa" [8]="Vừa" [9]="Khó" [10]="Khó" [11]="Vừa" )
declare -A KY_NANG=(
  [1]="quan sát trạng thái hệ thống một cách cẩn thận"
  [2]="đọc thông báo lỗi khi kiểm tra file cấu hình"
  [3]="đọc thông báo lỗi khi tải image"
  [4]="tìm hiểu thứ gì đang chiếm tài nguyên của máy"
  [5]="so sánh giá trị mong đợi với giá trị thực tế"
  [6]="đọc thông báo lỗi khi kiểm tra file cấu hình"
  [7]="đọc nhật ký ứng dụng và nội dung trang lỗi"
  [8]="đọc nhật ký của từng container"
  [9]="tìm hiểu vì sao một container không 'khỏe'"
  [10]="phân tích khi mọi thứ trông bình thường mà vẫn lỗi"
  [11]="đọc lỗi khi đóng gói image"
)

loi() { echo "LỖI: $*" >&2; }

can_docker() {
  [ "${LAB_DRY:-0}" = "1" ] && return 0
  if ! command -v docker >/dev/null 2>&1; then
    loi "Không tìm thấy lệnh docker. Mở Docker Desktop và bật tích hợp WSL (Settings > Resources > WSL integration)."
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    loi "Cần Docker Compose v2 (lệnh 'docker compose')."
    exit 1
  fi
}

# Chạy docker compose bên trong thư mục hệ thống của lab
dc() { ( cd "$LAB/he-thong" && docker compose "$@" ); }

# thay <file> <chuỗi cũ> <chuỗi mới>: thay đúng một lần, báo lỗi nếu không tìm thấy chuỗi cũ
thay() {
  local f="$1" tim="$2" moi="$3" nd
  nd="$(cat "$f"; printf x)"; nd="${nd%x}"
  if [[ "$nd" != *"$tim"* ]]; then
    loi "Không áp dụng được đề này: file mẫu '$f' không còn chuỗi cần thay."
    exit 1
  fi
  printf '%s' "${nd/"$tim"/"$moi"}" > "$f"
}

tao_ban_sao() {
  if [ -e "$LAB" ] && [ ! -f "$MARKER" ]; then
    loi "Thư mục '$LAB' đã tồn tại và không phải do lab.sh tạo. Đổi sang thư mục khác bằng LAB_DIR=/duong/dan/khac."
    exit 1
  fi
  case "$LAB" in ""|"/"|"$HOME"|"$HOME/") loi "Đường dẫn LAB không hợp lệ: '$LAB'"; exit 1;; esac
  rm -rf "$LAB"
  mkdir -p "$LAB"
  cp -r "$MAU/." "$LAB/"
  mv "$LAB/he-thong/env.mau" "$LAB/he-thong/.env"
  # Bỏ ký tự xuống dòng kiểu Windows (CRLF) nếu file mẫu bị lấy về kiểu Windows
  find "$LAB" -type f -exec sed -i 's/\r$//' {} +
  touch "$MARKER"
}

don_docker() {
  if [ -d "$LAB/he-thong" ]; then dc down -v --remove-orphans >/dev/null 2>&1; fi
  docker rm -f "$BLOCKER" >/dev/null 2>&1
  return 0
}

# ---------------------------------------------------------------------
# 11 ĐỀ BÀI. Mỗi hàm chỉ sửa file trong thư mục lab/ (hoặc dựng thứ cản đường).
# Bạn không cần đọc phần này để làm bài.
# ---------------------------------------------------------------------
CP="$LAB/he-thong/compose.yaml"
f01() { thay "$CP" '"${HTTP_PORT:-8080}:80"' '"${HTTP_PORT:-8080}:8080"'; }
f02() { thay "$CP" '      REDIS_HOST: redis' '     REDIS_HOST: redis'; }
f03() { thay "$CP" 'image: redis:7-alpine' 'image: redis:7-alpin'; }
f04() { docker rm -f "$BLOCKER" >/dev/null 2>&1; docker run -d --name "$BLOCKER" -p "${PORT}:80" nginx:1.27-alpine >/dev/null 2>&1 \
          || echo "(Cảnh báo: không dựng được vật cản; có thể cổng ${PORT} đang bị chương trình khác giữ sẵn.)"; }
f05() { thay "$LAB/he-thong/.env" 'HTTP_PORT=8090' 'HTTP_PROT=8090'; }
f06() { thay "$CP" $'\nvolumes:\n  du-lieu-redis:' ''; }
f07() { thay "$CP" 'REDIS_HOST: redis' 'REDIS_HOST: redis-db'; }
f08() { thay "$LAB/he-thong/nginx/default.conf" 'proxy_pass http://web:8000;' 'proxy_pass http://trangweb:8000;'; }
f09() { thay "$CP" '"redis-cli", "ping"' '"redis-cli", "-p", "6380", "ping"'; }
f10() { thay "$LAB/ung-dung/Dockerfile" '"0.0.0.0:8000"' '"127.0.0.1:8000"'; }
f11() { thay "$LAB/ung-dung/Dockerfile" 'COPY requirements.txt .' 'COPY requirement.txt .'; }

# ---------------------------------------------------------------------
# Các lệnh
# ---------------------------------------------------------------------
cmd_pha() {
  can_docker
  local n="${1:-ngau-nhien}"
  if [ "$n" = "ngau-nhien" ]; then n=$(( RANDOM % SO_DE + 1 )); fi
  if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt "$SO_DE" ]; then
    loi "Số đề phải từ 1 đến $SO_DE, hoặc gõ: ngau-nhien"; exit 1
  fi
  echo "Đang chuẩn bị bản sao sạch và phá hệ thống..."
  don_docker
  tao_ban_sao
  "f$(printf '%02d' "$n")" || exit 1
  echo "$n" > "$HIEN_TAI"
  echo "Đang dựng hệ thống (lần đầu có thể mất vài phút vì phải tải image)..."
  ( cd "$LAB/he-thong" && timeout 300 docker compose up -d --build ) >/dev/null 2>&1 || true
  cat <<EOF

=====================  ĐỀ SỐ $n  (mức: ${MUC_DO[$n]})  =====================
Hệ thống "Sổ lưu bút" trong thư mục sau vừa bị làm hỏng:

    $LAB/he-thong

NHIỆM VỤ: tự tìm nguyên nhân và sửa, sao cho:
  1. Cả 3 dịch vụ (nginx, web, redis) chạy và "khỏe".
  2. Mở http://localhost:$PORT thấy trang sổ lưu bút (không có khung lỗi đỏ) và gửi được lời nhắn.

Bắt đầu bằng:
    cd "$LAB/he-thong"
    docker compose ps

Nhớ: file cần sửa nằm trong thư mục lab/. Sửa xong thì chạy lại: docker compose up -d --build
Kỹ năng đề này luyện: ${KY_NANG[$n]}.

Khi nghĩ là xong:   bash lab.sh kiem-tra
Bí:                 bash lab.sh goi-y        (gợi ý mức 1; thêm số 2 hoặc 3 để gợi ý rõ hơn)
Xem đáp án:         bash lab.sh dap-an
Làm lại từ đầu:     bash lab.sh lam-lai      (đưa hệ thống về trạng thái khỏe)
================================================================
EOF
}

cmd_kiem_tra() {
  can_docker
  [ -d "$LAB/he-thong" ] || { loi "Chưa có bài. Chạy: bash lab.sh pha ngau-nhien"; exit 1; }
  command -v curl >/dev/null 2>&1 || { loi "Cần curl. Cài bằng: sudo apt install -y curl"; exit 1; }
  local ok=1 ds n tt body ma

  ds="$(docker ps --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}}')"
  n="$(printf '%s\n' "$ds" | grep -c .)"
  if [ "$n" -ge 3 ]; then echo "ĐẠT   có $n container đang chạy"; else echo "CHƯA  mới có $n/3 container đang chạy"; ok=0; fi

  tt="$(docker ps --filter "label=com.docker.compose.project=$PROJ" --format '{{.Names}}: {{.Status}}')"
  if printf '%s' "$tt" | grep -Eqi 'unhealthy|restarting|starting'; then
    echo "CHƯA  có container chưa khỏe hoặc đang khởi động lại:"; printf '%s\n' "$tt" | grep -Ei 'unhealthy|restarting|starting' | sed 's/^/        /'; ok=0
  else
    echo "ĐẠT   không có container nào lỗi hoặc đang khởi động lại"
  fi

  local tmp code; tmp="$(mktemp)"
  code="$(curl -s -o "$tmp" -w '%{http_code}' --max-time 5 "http://localhost:$PORT/" 2>/dev/null)"; ma=$?
  body="$(cat "$tmp")"; rm -f "$tmp"
  if [ "$ma" -ne 0 ] || [ "$code" = "000" ]; then
    echo "CHƯA  không mở được http://localhost:$PORT (không có phản hồi)"; ok=0
  elif printf '%s' "$body" | grep -q 'class="err"'; then
    echo "CHƯA  trang mở được nhưng đang hiện khung lỗi đỏ (mã $code)"; ok=0
  elif [ "$code" != "200" ]; then
    echo "CHƯA  máy chủ trả về mã $code thay vì 200"; ok=0
  elif printf '%s' "$body" | grep -q 'Container ph'; then
    echo "ĐẠT   trang sổ lưu bút mở được tại http://localhost:$PORT"
    local dau="kt-$(date +%s)"
    curl -s -L --max-time 5 -d "text=$dau" "http://localhost:$PORT/notes" >/dev/null 2>&1
    if curl -s --max-time 5 "http://localhost:$PORT/" | grep -q "$dau"; then
      echo "ĐẠT   gửi lời nhắn và đọc lại được"
    else
      echo "CHƯA  gửi lời nhắn nhưng không đọc lại được"; ok=0
    fi
  else
    echo "CHƯA  trang mở được nhưng không phải trang sổ lưu bút (có thể đang hiện trang của chương trình khác)"; ok=0
  fi

  echo
  if [ "$ok" = "1" ]; then
    echo "HOÀN THÀNH! Bạn đã sửa được hệ thống."
    echo "Xem đáp án để đối chiếu cách nghĩ:  bash lab.sh dap-an"
    echo "Thử đề khác:                        bash lab.sh pha ngau-nhien"
  else
    echo "Chưa xong. Tiếp tục tìm lỗi (docker compose ps, docker compose logs, docker compose config...)."
  fi
}

lay_de_hien_tai() {
  [ -f "$HIEN_TAI" ] || { loi "Chưa có đề nào. Chạy: bash lab.sh pha ngau-nhien"; exit 1; }
  cat "$HIEN_TAI"
}

# in một mục (## Tiêu đề) trong file đáp án
in_muc() { tr -d '\r' < "$1" | awk -v t="## $2" '$0==t{p=1;next} /^## /{p=0} p'; }

cmd_goi_y() {
  local n m="${1:-1}"; n="$(lay_de_hien_tai)" || exit 1
  [[ "$m" =~ ^[123]$ ]] || { loi "Gợi ý chỉ có mức 1, 2 hoặc 3."; exit 1; }
  echo "--- Gợi ý $m cho đề số $n ---"
  in_muc "$DAP_AN/$(printf '%02d' "$n").md" "Gợi ý $m"
  [ "$m" -lt 3 ] && echo "(Muốn gợi ý rõ hơn: bash lab.sh goi-y $((m+1)))"
  return 0
}

cmd_dap_an() {
  local n; n="$(lay_de_hien_tai)" || exit 1
  echo "=== ĐÁP ÁN đề số $n ==="
  in_muc "$DAP_AN/$(printf '%02d' "$n").md" "Đáp án"
}

cmd_lam_lai() {
  can_docker
  echo "Đưa hệ thống về trạng thái khỏe..."
  don_docker
  tao_ban_sao
  if dc up -d --build --wait --wait-timeout 180 >/dev/null 2>&1; then
    echo "Xong. Hệ thống khỏe tại http://localhost:$PORT (chưa có lỗi nào)."
  else
    echo "Hệ thống chưa lên được. Kiểm tra: cổng $PORT có đang bị chương trình khác giữ không?  (cd \"$LAB/he-thong\" && docker compose ps)"
  fi
  rm -f "$HIEN_TAI"
}

cmd_xoa() {
  can_docker
  don_docker
  docker rmi loi-lab-web:1.0 >/dev/null 2>&1
  if [ -f "$MARKER" ]; then rm -rf "$LAB"; echo "Đã xóa bản sao và mọi tài nguyên Docker của bài tập (loi-lab)."
  else echo "Không có bản sao nào để xóa."; fi
}

cmd_danh_sach() {
  echo "Có $SO_DE đề. Chỉ liệt kê mức độ và kỹ năng, không tiết lộ nguyên nhân:"
  local i
  for i in $(seq 1 "$SO_DE"); do printf '  Đề %2d  [%s]  %s\n' "$i" "${MUC_DO[$i]}" "${KY_NANG[$i]}"; done
}

# Thử áp dụng cả 11 đề lên bản sao tạm (không gọi Docker) để chắc file mẫu còn khớp.
# Hữu ích khi trình soạn thảo tự định dạng lại file trong mau/ làm đề không áp dụng được.
cmd_tu_kiem_tra() {
  local tmp i loi_so=0
  tmp="$(mktemp -d)"
  for i in $(seq 1 "$SO_DE"); do
    if LAB_DRY=1 LAB_DIR="$tmp/lab$i" bash "$AQUI/lab.sh" pha "$i" >/dev/null 2>&1; then
      printf '  Đề %2d  áp dụng được\n' "$i"
    else
      printf '  Đề %2d  KHÔNG áp dụng được (file trong mau/ đã bị sửa hoặc định dạng lại)\n' "$i"; loi_so=$((loi_so+1))
    fi
  done
  rm -rf "$tmp"
  if [ "$loi_so" -eq 0 ]; then echo "Tất cả $SO_DE đề đều áp dụng được."
  else echo "Có $loi_so đề lỗi. Khôi phục file mẫu: git checkout -- \"$MAU\""; return 1; fi
}

cmd_giup() {
  cat <<'EOF'
Bài tập sửa lỗi Docker. Dùng:  bash lab.sh <lệnh>

  pha <số|ngau-nhien>   Phá hệ thống bằng một lỗi (khuyên dùng: ngau-nhien)
  kiem-tra              Kiểm tra xem bạn đã sửa xong chưa
  goi-y [1|2|3]         Gợi ý cho đề hiện tại (mức 1 nhẹ nhất)
  dap-an                Xem đáp án đề hiện tại
  lam-lai               Đưa hệ thống về trạng thái khỏe, xóa đề hiện tại
  danh-sach             Liệt kê các đề (mức độ, kỹ năng)
  tu-kiem-tra           Thử áp dụng cả 11 đề lên bản sao tạm (không cần Docker) để chắc file mẫu còn khớp
  xoa                  Dọn sạch bài tập (bản sao và tài nguyên Docker tên loi-lab)
  vao                   In lệnh để đi vào thư mục làm bài

Biến tùy chọn:  LAB_DIR=/duong/dan  đặt thư mục làm bài ở chỗ khác (ví dụ ~/loi-lab trên ổ Linux cho nhanh)
EOF
}

case "${1:-giup}" in
  pha)        shift; cmd_pha "${1:-ngau-nhien}";;
  kiem-tra)   cmd_kiem_tra;;
  goi-y)      shift; cmd_goi_y "${1:-1}";;
  dap-an)     cmd_dap_an;;
  lam-lai)    cmd_lam_lai;;
  danh-sach)  cmd_danh_sach;;
  tu-kiem-tra) cmd_tu_kiem_tra;;
  xoa)        cmd_xoa;;
  vao)        echo "cd \"$LAB/he-thong\"";;
  giup|-h|--help) cmd_giup;;
  *)          loi "Lệnh không biết: $1"; cmd_giup; exit 1;;
esac
