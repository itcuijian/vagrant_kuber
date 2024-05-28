# README #

这是一个通过 `Vagrant` 和 `VirtualBox` 虚拟机来运行 `Kubernetes` 简单配置，通过 `Vagrant` 来启动就可以构建一个简单的 `Kubernetes` 集群。

### 环境配置 ###

* Vagrant: >= 2.4.1
* VirtualBox: >= 6.1.5

### 初始化 ###

安装好 `Vagrant` 和 `VirtualBox` 之后，首先将 `.config.example.yaml` 文件复制一份，命名为 `.config.yaml` ，并在文件中配置好 `Master` 节点和 `Worker` 节点的相关配置。

其中 `bridge` 配置为宿主机的网卡名称，表明虚拟机集群使用该网卡作为桥接网卡，其他的配置可以根据实际情况来定。

因为已经配置好 `Vagrantfile` 文件，在设置好集群节点参数之后就可以使用 `Vagrant` 的启动命令来启动集群：

```
vagrant up
```

在启动时，会执行目录下的 `bootstrap.sh` 脚本，该脚本会安装 `kubeadm` 等一些程序，如果需要安装其他的程序或者执行其他一些指令，可以修改 `bootstrap.sh` 脚本文件。

### Kubernetes 启动 ###

在集群的所有节点安装了 `kubeadm` ，可以使用它来启动 `Kubernetes` 集群，首先进入到 `Master` 节点：

```
vagrant ssh [master_name]
```

其中 `master_name` 为 `Master` 节点的名字，在 `.config.yaml` 里面配置。

进入到 `Master` 节点之后，切换到 `root` 用户，通过一下节点来启动 `Kubernetes` ：

```
kubeadm init --config /etc/kubernetes/kubeadm.yaml
```

该启动指令的最后会输出一个 `kubeadm join` 指令，该指令就是将 `Worker` 节点加入到集群的指令：

```
kubeadm join 10.0.0.30:6443 --token [token] \
        --discovery-token-ca-cert-hash sha256:[sha256]
```

将该指令保存好，以后部署 `Worker` 节点的时候会用到。

> `10.0.0.30` 为 `Master` 节点的 IP 地址。

启动完成之后可以保存好 `Kubernetes` 集群的安全配置文件到 `.kube` 目录下：

```
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config
```

启动了通过 `kubectl get nodes` 指令可以看到集群的 `Master` 节点的状态是 `NotReady` ，通过 `kubectl describe node master` 命令的输出可以看到 `Conditions:` 里面的说明是：`'NetworkPluginNotReady'` ，表明该集群还没有部署网络插件。

根据上面的指示，部署 `Flunnel` 网络插件（当然也可以是其他网络插件）：

```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

其他 `Kubernetes` 插件可以参考 `master.sh` 来自己部署。

### 部署 Kubernetes 的 Worker 节点 ###

首先进入到 `Worker` 节点：

```
vagrant ssh [node_name]
```

其中 `node_name` 是 `Worker` 节点的名字，配置在 `.config.yaml` 里面。

在进入 `Worker` 节点之后，切换到 `root` 用户，执行上面保存好 `kubeadm join` 的指令：

```
kubeadm join 10.0.0.30:6443 --token 00bwbx.uvnaa2ewjflwu1ry \
         --discovery-token-ca-cert-hash sha256:00eb62a2a6020f94132e3fe1ab721349bbcd3e9b94da9654cfe15f2985ebd711
```

这样就可以将一个 `Worker` 节点加入到 `Kubernetes` 集群了。
