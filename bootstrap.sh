#!/bin/bash

# 设置阿里云源
cat <<EOF | tee /etc/apt/source.list
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy main restricted
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy main restricted
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates main restricted
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates main restricted
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy universe
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy universe
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates universe
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates universe
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy multiverse
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy multiverse
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates multiverse
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-updates multiverse
deb http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security main restricted
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security main restricted
deb http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security universe
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security universe
deb http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security multiverse
deb-src http://mirrors.cloud.aliyuncs.com/ubuntu jammy-security multiverse
EOF

# 关闭交换分区
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
swapoff -a

#  添加Google的GPG密钥
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
 
# 添加Kubernetes的APT仓库
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

# 添加阿里云 Docker 的 GPG 密钥
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 docker 的阿里云源
cat <<EOF | tee /etc/apt/sources.list.d/docker.list
deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable
EOF

# 安装 Docker kubelet kubeadm
apt update && apt install -y docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl
# 锁定版本
apt-mark hold kubeadm kubelet kubectl

# 修改 /etc/containerd/config.toml 开启 cri
# issue: https://github.com/containerd/containerd/issues/8139
sed -i 's/^disabled_plugins/#&/' /etc/containerd/config.toml 
# cat >> /etc/containerd/config.toml <<EOF 
# version = 2
# [plugins]
#   [plugins."io.containerd.grpc.v1.cri"]
#     sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
#     [plugins."io.containerd.grpc.v1.cri".containerd]
#       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
#         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#           runtime_type = "io.containerd.runc.v2"
#           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#             SystemdCgroup = true
# EOF

# 重启 containerd
systemctl restart containerd.service

# 添加 kubeadm 启动配置
cp /vagrant/kubeadm.yaml /etc/kubernetes/kubeadm.yaml
cat >> /etc/kubernetes/kubeadm.yaml <<EOF
localAPIEndpoint:
  advertiseAddress: $2
  bindPort: 6443
EOF
