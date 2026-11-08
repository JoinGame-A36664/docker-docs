"""API của ứng dụng "Việc cần làm".

Chương trình này chỉ làm 4 việc: xem danh sách, thêm, đánh dấu xong/chưa xong, xóa.
Mọi dữ liệu nằm trong PostgreSQL. Cấu hình lấy từ biến môi trường.
"""
import os

import psycopg
from flask import Flask, jsonify, request

app = Flask(__name__)

MAX_TITLE = 200


def doc_mat_khau():
    """Đọc mật khẩu cơ sở dữ liệu.

    Cách chuẩn: mật khẩu nằm trong một FILE (Docker đặt ở /run/secrets/...), đường dẫn file
    được truyền qua biến DB_PASSWORD_FILE. Nhờ vậy mật khẩu không hiện trong cấu hình hay nhật ký.
    Nếu không có file thì dùng biến DB_PASSWORD (chỉ để thử nhanh trên máy cá nhân).
    """
    duong_dan = os.getenv("DB_PASSWORD_FILE")
    if duong_dan and os.path.exists(duong_dan):
        with open(duong_dan, encoding="utf-8") as f:
            return f.read().strip()
    return os.getenv("DB_PASSWORD", "")


def thong_tin_ket_noi():
    return dict(
        host=os.getenv("DB_HOST", "db"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "appdb"),
        user=os.getenv("DB_USER", "app"),
        password=doc_mat_khau(),
        connect_timeout=3,
    )


def chay(sql, tham_so=(), kieu="all"):
    """Chạy một câu lệnh SQL. Mỗi lần gọi mở một kết nối, xong là đóng (đủ dùng cho bài học).

    kieu = "all"   -> trả về mọi dòng
           "one"   -> trả về một dòng (hoặc None)
           "count" -> trả về số dòng bị ảnh hưởng
    Khi thoát khỏi khối "with" mà không có lỗi, psycopg tự lưu (commit) thay đổi.
    """
    with psycopg.connect(**thong_tin_ket_noi()) as conn:
        with conn.cursor() as cur:
            cur.execute(sql, tham_so)
            if kieu == "all":
                return cur.fetchall()
            if kieu == "one":
                return cur.fetchone()
            return cur.rowcount


def thanh_dict(dong):
    return {"id": dong[0], "title": dong[1], "done": dong[2]}


@app.errorhandler(psycopg.Error)
def loi_co_so_du_lieu(_loi):
    # Không in chi tiết lỗi ra cho người dùng (có thể lộ thông tin nội bộ); chi tiết đã nằm trong nhật ký.
    app.logger.exception("Loi co so du lieu")
    return jsonify(error="Không kết nối được cơ sở dữ liệu"), 503


@app.get("/api/tasks")
def danh_sach():
    dong = chay("SELECT id, title, done FROM tasks ORDER BY id DESC LIMIT 200")
    return jsonify([thanh_dict(d) for d in dong])


@app.post("/api/tasks")
def them():
    du_lieu = request.get_json(silent=True) or {}
    tieu_de = str(du_lieu.get("title", "")).strip()
    if not tieu_de or len(tieu_de) > MAX_TITLE:
        return jsonify(error="Tiêu đề phải từ 1 đến %d ký tự" % MAX_TITLE), 400
    dong = chay(
        "INSERT INTO tasks (title) VALUES (%s) RETURNING id, title, done", (tieu_de,), "one"
    )
    return jsonify(thanh_dict(dong)), 201


@app.patch("/api/tasks/<int:task_id>")
def doi_trang_thai(task_id):
    dong = chay(
        "UPDATE tasks SET done = NOT done WHERE id = %s RETURNING id, title, done",
        (task_id,),
        "one",
    )
    if dong is None:
        return jsonify(error="Không tìm thấy công việc"), 404
    return jsonify(thanh_dict(dong))


@app.delete("/api/tasks/<int:task_id>")
def xoa(task_id):
    so_dong = chay("DELETE FROM tasks WHERE id = %s", (task_id,), "count")
    if so_dong == 0:
        return jsonify(error="Không tìm thấy công việc"), 404
    return "", 204


@app.get("/api/health")
def suc_khoe():
    """Docker gọi đường này để biết API "khỏe" chưa. Khỏe = chạy được và nói chuyện được với cơ sở dữ liệu."""
    try:
        chay("SELECT 1", (), "one")
    except psycopg.Error:
        return jsonify(status="loi", db=False), 503
    return jsonify(status="ok", db=True)
