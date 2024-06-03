#!/bin/bash

# 设置阿里云源
cat <<EOF | sudo tee /etc/apt/source.list
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
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo swapoff -a

# 添加Kubernetes的APT仓库
curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/kubernetes-apt-keyring.gpg > /dev/null
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

# 添加阿里云 Docker 的 GPG 密钥，添加 docker 的阿里云源
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable
EOF

# 添加 helm 的APT仓库
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
cat <<EOF | tee /etc/apt/sources.list.d/helm-stable-debian.list
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main
EOF

if [ "$1" == "master" ]; then
  # 安装 Docker kubelet kubeadm helm
  sudo apt update && apt install -y containerd.io kubelet kubeadm kubectl helm
  # 锁定版本
  sudo apt-mark hold kubeadm kubelet kubectl

  # 添加 kubeadm 启动配置
  cat <<EOF | sudo tee /etc/kubernetes/kubeadm.yaml 
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  name: "$1"
localAPIEndpoint:
  advertiseAddress: $2
  bindPort: 6443
---
EOF

  sudo cat /vagrant/kubeadm.yaml >> /etc/kubernetes/kubeadm.yaml

else
  # 安装 kubelet kubeadm helm
  sudo apt update && apt install -y containerd.io kubelet kubeadm
  # 锁定版本
  sudo apt-mark hold kubeadm kubelet
fi

# sudo apt-get install -y lvm2

# 修改 /etc/containerd/config.toml 开启 cri
# issue: https://github.com/containerd/containerd/issues/8139
sudo sed -i 's/^disabled_plugins/#&/' /etc/containerd/config.toml 
# 将 cgroups 设置为 SystemdCgroup
sudo cat >> /etc/containerd/config.toml <<EOF 
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF

# 重启 containerd
sudo systemctl restart containerd.service

# 添加节点IP分配参数
cat <<EOF | tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--node-ip=$2"
EOF
# 重启 kubelet
sudo systemctl restart kubelet

# 加载 br_netfilter 内核模块，临时修改，重启失效
sudo modprobe br_netfilter
sudo modprobe rbd
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

# 开机自动设置 ip_forward 为 1
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# 开机自动加载 br_netfilter 内核模块
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
rbd
EOF

# 重启生效
sudo sysctl --system

# 开启时间同步
sudo timedatectl set-ntp on
sudo timedatectl set-timezone Asia/Shanghai

# 关闭防火墙
sudo systemctl stop ufw
sudo systemctl disable ufw
