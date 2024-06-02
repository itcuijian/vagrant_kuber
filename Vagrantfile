# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version '>= 2.4.1'

# requires
require 'yaml'

configs = YAML.load_file('.config.yaml')
vm_list = configs['nodes']

Vagrant.configure(configs['apiVersion']) do |config|
  config.vm.box = "ubuntu/jammy64"
  vm_list.each do |item|
    config.vm.define item["name"] do |node|
      node.vm.provider "virtualbox" do |vbox|
        vbox.name = item["name"];  #虚拟机名称
        vbox.memory = item["mem"]; #内存
        vbox.cpus = item["cpu"];   #CPU
      end

      node.vm.box_check_update = false
      node.vm.disk :disk, size: "10GB", name: "vdb"

      # 设置同步目录
      node.vm.synced_folder ".", "/vagrant", type: "virtualbox"

      # 设置hostname
      node.vm.hostname = item["hostname"]

      # 设置IP
      node.vm.network "public_network", ip: item["ipAddr"], bridge: configs['bridge'], auto_config: true

      # 执行shell脚本
      node.vm.provision "shell" do |script|
        script.path = "bootstrap.sh"     #脚本路径
        script.args = [ item["type"], item["ipAddr"] ]   #传递参数
      end
    end
  end
end
