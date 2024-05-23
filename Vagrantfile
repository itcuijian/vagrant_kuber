vm_list = [
  {
    "name" => "vagrant.kuber.master",
    "type" => "master",
    "cpu" => "2",
    "mem" => "2048",
    "ip_addr" => "10.0.0.30",
  },
  {
    "name" => "vagrant.kuber.node1",
    "type" => "node",
    "cpu" => "2",
    "mem" => "2048",
    "ip_addr" => "10.0.0.31",
  },
  {
    "name" => "vagrant.kuber.node2",
    "type" => "node",
    "cpu" => "2",
    "mem" => "2048",
    "ip_addr" => "10.0.0.32",
  }
]

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  vm_list.each do |item|
    config.vm.define item["name"] do |node|
      node.vm.provider "virtualbox" do |vbox|
        vbox.name = item["name"];  #虚拟机名称
        vbox.memory = item["mem"]; #内存
        vbox.cpus = item["cpu"];   #CPU
      end

      node.vm.box_check_update = false

      # 设置hostname
      node.vm.hostname = item["name"]

      # 设置IP
      node.vm.network "public_network", ip: item["ip_addr"], bridge: "enp86s0", auto_config: true

      # 执行shell脚本
      node.vm.provision "shell" do |script|
        script.path = "/usr/bin/echo"   #脚本路径
        script.args = [ item["type"] ]   #传递参数
      end
    end
  end
end
