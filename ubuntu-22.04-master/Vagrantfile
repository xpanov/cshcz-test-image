# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "image-test" do |device|
    device.vm.box = "mybox"
    device.vm.box_check_update = false
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "4096"
  end

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.verbose = true
    ansible.extra_vars = {
      ansible_python_interpreter: "/usr/bin/python3",
    }
  end
end
