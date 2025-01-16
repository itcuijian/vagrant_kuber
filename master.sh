# 根据配置文件执行 kubeadm
kubeadm init --config /etc/kubernetes/kubeadm.yaml

# 将生成的安全配置文件复制到 ~/.kube 目录，kubectl 使用该目录下的配置文件访问集群
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config

# 网络插件
# 需要修改网卡 `--iface=enp0s8`
kubectl apply -f /vagrant/examples/flannel/kube-flannel.yml

# 安装面板工具
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -n kubernetes-dashboard --create-namespace -f examples/dashboard/values.yaml
# 创建 Admin 用户
kubectl apply -f examples/dashboard/dashboard-user.yaml
kubectl apply -f examples/dashboard/dashboard-user-token.yaml
# 获取 token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
# 获取访问端口
kubectl -n kubernetes-dashboard get svc | grep kubernetes-dashboard-kong-proxy
# 访问
# https://10.0.0.30:22762

# 安装Metrics Server

# 存储插件
# sudo apt install ceph-common
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/common.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/operator.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/cluster.yaml
# 设置镜像源，给 operator.yaml 添加以下内容，去掉前面的注释
# ROOK_CSI_REGISTRAR_IMAGE: "registry.aliyuncs.com/google_containers/csi-node-driver-registrar:v2.8.0"
# ROOK_CSI_RESIZER_IMAGE: "registry.aliyuncs.com/google_containers/csi-resizer:v1.8.0"
# ROOK_CSI_PROVISIONER_IMAGE: "registry.aliyuncs.com/google_containers/csi-provisioner:v3.5.0"
# ROOK_CSI_SNAPSHOTTER_IMAGE: "registry.aliyuncs.com/google_containers/csi-snapshotter:v6.2.2"
# ROOK_CSI_ATTACHER_IMAGE: "registry.aliyuncs.com/google_containers/csi-attacher:v4.3.0"

