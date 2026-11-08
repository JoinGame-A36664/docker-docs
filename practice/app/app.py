"""Sổ lưu bút Docker: ứng dụng Flask nhỏ dùng để thực hành Docker.

- Đếm số lượt truy cập và lưu các lời nhắn trong Redis.
- Hiển thị tên container đang phục vụ (để thấy rõ mình đang nói chuyện với container nào).
- /health trả về 200 để Docker (HEALTHCHECK) và Compose biết ứng dụng còn sống.
"""
import os
import socket

import redis
from flask import Flask, jsonify, redirect, render_template_string, request, url_for

app = Flask(__name__)

TITLE = os.getenv("APP_TITLE", "Sổ lưu bút Docker")
MAX_NOTES = 50      # chỉ giữ 50 lời nhắn mới nhất
MAX_LENGTH = 200    # mỗi lời nhắn tối đa 200 ký tự

# Cấu hình lấy từ biến môi trường, đây là cách chuẩn để truyền cấu hình vào container.
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    decode_responses=True,
    socket_connect_timeout=2,
    socket_timeout=2,
)

PAGE = """<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{ title }}</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 640px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
    .meta { color: #555; font-size: .9rem; }
    .err { background: #fdecea; border: 1px solid #f5c2c0; padding: .75rem 1rem; border-radius: 6px; }
    form { display: flex; gap: .5rem; margin: 1rem 0; }
    input[type=text] { flex: 1; padding: .5rem; }
    li { margin: .25rem 0; }
  </style>
</head>
<body>
  <h1>{{ title }}</h1>
  <p class="meta">Container phục vụ: <code>{{ hostname }}</code></p>

  {% if error %}
    <div class="err">
      <strong>Không kết nối được tới Redis</strong> ({{ redis_host }}:{{ redis_port }}).<br>
      Lỗi: {{ error }}
    </div>
  {% else %}
    <p>Bạn là lượt truy cập thứ <strong>{{ visits }}</strong>.</p>
    <form method="post" action="{{ url_for('add_note') }}">
      <input type="text" name="text" maxlength="{{ max_length }}" placeholder="Viết lời nhắn..." required>
      <button type="submit">Gửi</button>
    </form>
    {% if notes %}
      <ul>{% for n in notes %}<li>{{ n }}</li>{% endfor %}</ul>
    {% else %}
      <p><em>Chưa có lời nhắn nào.</em></p>
    {% endif %}
  {% endif %}
</body>
</html>
"""


def render(**extra):
    ctx = dict(
        title=TITLE,
        hostname=socket.gethostname(),
        redis_host=REDIS_HOST,
        redis_port=REDIS_PORT,
        max_length=MAX_LENGTH,
        error=None,
        visits=0,
        notes=[],
    )
    ctx.update(extra)
    return render_template_string(PAGE, **ctx)


@app.get("/")
def index():
    try:
        visits = r.incr("visits")
        notes = r.lrange("notes", 0, 19)
    except redis.exceptions.RedisError as exc:
        # Redis chưa chạy / sai tên host: vẫn trả về trang giải thích thay vì sập.
        return render(error=type(exc).__name__ + ": " + str(exc)), 503
    return render(visits=visits, notes=notes)


@app.post("/notes")
def add_note():
    text = (request.form.get("text") or "").strip()[:MAX_LENGTH]
    if text:
        try:
            pipe = r.pipeline()
            pipe.lpush("notes", text)
            pipe.ltrim("notes", 0, MAX_NOTES - 1)
            pipe.execute()
        except redis.exceptions.RedisError:
            pass  # trang chủ sẽ hiển thị lỗi kết nối
    return redirect(url_for("index"))


@app.get("/api/notes")
def api_notes():
    try:
        return jsonify(notes=r.lrange("notes", 0, MAX_NOTES - 1), visits=int(r.get("visits") or 0))
    except redis.exceptions.RedisError as exc:
        return jsonify(error=type(exc).__name__), 503


@app.get("/health")
def health():
    """Trả 200 nếu tiến trình web còn sống. Có kèm trạng thái Redis để tiện quan sát."""
    try:
        redis_ok = bool(r.ping())
    except redis.exceptions.RedisError:
        redis_ok = False
    return jsonify(status="ok", redis=redis_ok, host=socket.gethostname())


if __name__ == "__main__":
    # Chỉ dùng khi chạy trực tiếp "python app.py" trên máy để thử. Trong container chạy bằng gunicorn.
    app.run(host="0.0.0.0", port=8000, debug=True)
