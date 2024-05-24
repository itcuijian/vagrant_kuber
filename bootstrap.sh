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
 
#  添加Kubernetes的APT仓库
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

# 安装 Docker
apt update && apt install -y kubelet kubeadm kubectl
