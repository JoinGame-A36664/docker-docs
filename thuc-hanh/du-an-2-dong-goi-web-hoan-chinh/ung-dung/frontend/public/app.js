// Phần giao diện: gọi API bằng đường /api/... (cùng địa chỉ với trang, nginx sẽ chuyển tiếp vào API).
const dsEl = document.getElementById("danh-sach");
const tbEl = document.getElementById("thong-bao");
const formEl = document.getElementById("form-them");
const nhapEl = document.getElementById("o-nhap");

function baoLoi(msg) { tbEl.textContent = msg || ""; }

async function goi(duongDan, tuyChon) {
  const kq = await fetch(duongDan, tuyChon);
  if (!kq.ok) {
    let noiDung = "Có lỗi xảy ra (mã " + kq.status + ")";
    try { noiDung = (await kq.json()).error || noiDung; } catch (_) {}
    throw new Error(noiDung);
  }
  return kq.status === 204 ? null : kq.json();
}

function ve(danhSach) {
  dsEl.textContent = "";
  if (danhSach.length === 0) {
    const li = document.createElement("li");
    li.className = "trong";
    li.textContent = "Chưa có việc nào. Hãy thêm việc đầu tiên!";
    dsEl.appendChild(li);
    return;
  }
  for (const viec of danhSach) {
    const li = document.createElement("li");
    if (viec.done) li.className = "xong";

    const nhan = document.createElement("span");
    nhan.className = "tieu-de";
    nhan.textContent = viec.title;            // textContent: luôn an toàn, không chạy nhầm mã HTML
    nhan.addEventListener("click", () => doi(viec.id));

    const nutXoa = document.createElement("button");
    nutXoa.className = "xoa";
    nutXoa.textContent = "Xóa";
    nutXoa.addEventListener("click", () => xoa(viec.id));

    li.append(nhan, nutXoa);
    dsEl.appendChild(li);
  }
}

async function tai() {
  try { ve(await goi("/api/tasks")); baoLoi(""); }
  catch (loi) { baoLoi(loi.message); }
}

async function doi(id) {
  try { await goi("/api/tasks/" + id, { method: "PATCH" }); await tai(); }
  catch (loi) { baoLoi(loi.message); }
}

async function xoa(id) {
  try { await goi("/api/tasks/" + id, { method: "DELETE" }); await tai(); }
  catch (loi) { baoLoi(loi.message); }
}

formEl.addEventListener("submit", async (e) => {
  e.preventDefault();
  const tieuDe = nhapEl.value.trim();
  if (!tieuDe) return;
  try {
    await goi("/api/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: tieuDe }),
    });
    nhapEl.value = "";
    await tai();
  } catch (loi) { baoLoi(loi.message); }
});

tai();
