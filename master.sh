# 根据配置文件执行 kubeadm
kubeadm init --config /etc/kubernetes/kubeadm.yaml

# 将生成的安全配置文件复制到 ~/.kube 目录，kubectl 使用该目录下的配置文件访问集群
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config

# 网络插件
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 存储插件
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/common.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/operator.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/cluster.yaml

