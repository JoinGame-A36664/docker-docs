# Kubernetes hiện nay: kind, kubeadm và Deployment đầu tiên

> Bài bổ sung (2026), thay cho cách cài cũ trong [Hướng dẫn cài đặt Kubernetes](../docker-coban/docker-thuchanh-caidat-kubernetes.md). Bài giữ nguyên bố cục "môi trường lab → cài đặt → tạo pod" của bài gốc.

____

# Mục lục
- [1. Kubernetes khác Docker / Swarm chỗ nào](#about)
- [2. Cách 1: học nhanh trên máy cá nhân với kind](#kind)
- [3. Cách 2: dựng cụm nhiều node với kubeadm](#kubeadm)
- [4. Deployment và Service đầu tiên](#first)
- [5. Các lệnh kubectl hay dùng](#kubectl)

____

# <a name="about">1. Kubernetes khác Docker / Swarm chỗ nào</a>
| Docker / Compose / Swarm | Kubernetes |
|---|---|
| container | **Pod** (nhóm 1 hoặc nhiều container chạy chung) |
| `docker service` (Swarm) | **Deployment** (quản lý số bản sao, cập nhật cuốn chiếu) |
| `-p 8080:80` / ingress mesh | **Service** (ổn định địa chỉ nội bộ) + **Ingress** (HTTP vào từ ngoài) |
| volume | **PersistentVolume / PersistentVolumeClaim** |
| `docker config` / `secret` | **ConfigMap / Secret** |
| file `compose.yaml` | file **manifest YAML** (`kubectl apply -f`) |

- Kubernetes không build image. Bạn build image bằng Docker (hoặc buildx) rồi đẩy lên registry; cụm kéo về chạy.
- Runtime bên dưới là **containerd** (hoặc CRI-O), không phải Docker Engine, nhưng image Docker chạy bình thường.

# <a name="kind">2. Cách 1: học nhanh trên máy cá nhân với kind</a>
`kind` (Kubernetes IN Docker) dựng cả cụm Kubernetes bằng container Docker, mất khoảng 1 phút và xóa đi dễ dàng. Phù hợp để học và thực hành, có chạy được trên Windows (Docker Desktop), macOS và Linux.

- Cài `kubectl` và `kind` (xem hướng dẫn mới nhất tại kubernetes.io và kind.sigs.k8s.io). Ví dụ Windows dùng `winget`:
  ```powershell
  winget install Kubernetes.kubectl
  winget install Kubernetes.kind
  ```
  Linux/macOS dùng trình cài gói của hệ thống hoặc tải file nhị phân từ trang phát hành chính thức.
- Tạo cụm:
  ```sh
  kind create cluster --name lab
  kubectl cluster-info --context kind-lab
  kubectl get nodes
  ```
- Cụm nhiều node (1 control-plane + 2 worker): lưu file `kind-3nodes.yaml`
  ```yaml
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  nodes:
    - role: control-plane
    - role: worker
    - role: worker
  ```
  ```sh
  kind create cluster --name lab3 --config kind-3nodes.yaml
  ```
- Nạp image build ở máy vào cụm (không cần registry khi học):
  ```sh
  docker build -t web_server:1.0 .
  kind load docker-image web_server:1.0 --name lab
  ```
- Xóa cụm: `kind delete cluster --name lab`
- Lựa chọn khác: **minikube** (`minikube start`), hoặc bật Kubernetes trong Docker Desktop (Settings > Kubernetes).

# <a name="kubeadm">3. Cách 2: dựng cụm nhiều node với kubeadm</a>
Môi trường LAB (thay cho bài gốc dùng CentOS 7): 03 máy Ubuntu Server 24.04, mỗi máy tối thiểu 2 CPU, 2 GB RAM, đặt hostname và IP tĩnh khác nhau:

| Hostname | Vai trò |
|---|---|
| `k8s-master` | control-plane |
| `k8s-node1`, `k8s-node2` | worker |

## 3.1 Việc cần làm trên **cả 3 máy**
- Tắt swap (Kubernetes yêu cầu):
  ```sh
  sudo swapoff -a
  sudo sed -i '/ swap / s/^/#/' /etc/fstab
  ```
- Nạp module nhân và bật chuyển tiếp mạng:
  ```sh
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
  overlay
  br_netfilter
  EOF
  sudo modprobe overlay && sudo modprobe br_netfilter

  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-iptables  = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward                 = 1
  EOF
  sudo sysctl --system
  ```
- Cài **containerd** (từ kho apt của Docker, cùng kho với bài [Cài đặt Docker](../docker-5m/01.Caidatdocker.md); bạn chỉ cần gói `containerd.io`) rồi bật `SystemdCgroup`:
  ```sh
  sudo apt-get install -y containerd.io
  sudo mkdir -p /etc/containerd
  containerd config default | sudo tee /etc/containerd/config.toml
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  sudo systemctl restart containerd && sudo systemctl enable containerd
  ```
- Cài `kubeadm`, `kubelet`, `kubectl` từ kho `pkgs.k8s.io` (kho cũ `apt.kubernetes.io` / `yum.kubernetes.io` đã đóng). Đặt `K8S_MINOR` là nhánh phiên bản đang được hỗ trợ, xem danh sách tại kubernetes.io/releases (ví dụ dưới là `v1.34`):
  ```sh
  K8S_MINOR=v1.34
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg
  curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  ```
- Tường lửa: mở cổng `6443/tcp` (API server), `10250/tcp` (kubelet), `2379-2380/tcp` (etcd, trên master) và cổng của mạng pod (flannel dùng `8472/udp`). Môi trường lab có thể tắt `ufw` tạm thời.

## 3.2 Khởi tạo trên node **master**
```sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<IP_cua_master>
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- Cuối kết quả có lệnh `kubeadm join ... --token ... --discovery-token-ca-cert-hash sha256:...`, hãy lưu lại. Mất thì tạo lại bằng: `kubeadm token create --print-join-command`.
- Cài **mạng cho pod (CNI)**. Bản gốc dùng flannel cấu hình tay với etcd; nay chỉ cần một lệnh (kiểm tra địa chỉ manifest mới nhất trên trang dự án flannel):
  ```sh
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
  ```

## 3.3 Join các node **worker**
Chạy lệnh `kubeadm join ...` đã lưu ở trên (với `sudo`) trên `k8s-node1` và `k8s-node2`. Quay lại master kiểm tra, node ở trạng thái `Ready` là xong (có thể mất 1-2 phút):
```sh
kubectl get nodes -o wide
```

# <a name="first">4. Deployment và Service đầu tiên</a>
Bản gốc tạo thẳng một Pod từ file `pod-webserver.yaml`. Cách thường dùng ngày nay là tạo **Deployment** (tự giữ đủ số bản sao, tự thay pod hỏng) và **Service** (địa chỉ ổn định để truy cập). Lưu thành `web.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
          resources:
            requests:
              cpu: 50m
              memory: 32Mi
            limits:
              memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```
```sh
kubectl apply -f web.yaml
kubectl get deploy,pods,svc -o wide
```
Mở trình duyệt vào `http://<IP_cua_bat_ky_node>:30080` (với kind, dùng `kubectl port-forward svc/web 8080:80` rồi mở `http://localhost:8080`).

- Mở rộng: `kubectl scale deploy/web --replicas=5`
- Cập nhật phiên bản không gián đoạn: `kubectl set image deploy/web web=nginx:1.27.3-alpine` rồi theo dõi `kubectl rollout status deploy/web`
- Quay về bản trước: `kubectl rollout undo deploy/web`
- Thử xóa một pod, Deployment sẽ tạo pod mới ngay: `kubectl delete pod <ten_pod>`

# <a name="kubectl">5. Các lệnh kubectl hay dùng</a>
| Lệnh | Tác dụng |
|---|---|
| `kubectl get pods -A` | Liệt kê pod ở mọi namespace |
| `kubectl describe pod <pod>` | Xem chi tiết và sự kiện (hay dùng khi pod lỗi) |
| `kubectl logs -f <pod>` | Xem log |
| `kubectl exec -it <pod> -- sh` | Vào trong container |
| `kubectl apply -f file.yaml` | Tạo / cập nhật tài nguyên theo file |
| `kubectl delete -f file.yaml` | Xóa tài nguyên theo file |
| `kubectl port-forward svc/web 8080:80` | Mở cổng từ máy bạn tới Service |
| `kubectl config get-contexts` | Xem các cụm đang cấu hình |

Gợi ý bước tiếp theo: chạy ứng dụng ở dự án thực hành ([`thuc-hanh/`](../../thuc-hanh/README.md)) trên kind bằng cách viết Deployment + Service cho từng thành phần. Đó là bài tập tự nhiên sau khi đã quen Compose.
