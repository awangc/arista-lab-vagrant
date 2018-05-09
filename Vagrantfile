# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
default_box = 'vEOS-lab-4.20.1F'
server_box = 'ubuntu/xenial64'
def path_exists?(path)
  File.directory?(path)
end

$dimage = ENV.fetch("DIMAGE", "netbricks")
$dtag = ENV.fetch("DTAG", "latest")
$dproject = ENV.fetch("DPROJECT", "williamofockham")
$nbpath = ENV.fetch("NBPATH", "../NetBricks")
$mgpath = ENV.fetch("MGPATH", "../MoonGen")
$dpdk_driver = ENV.fetch("DPDK_DRIVER", "uio_pci_generic")
$dpdk_devices = ENV.fetch("DPDK_DEVICES", "0000:00:08.0 0000:00:09.0")

Vagrant.configure(2) do |config|
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./helper_scripts/empty_playbook.yml"
    ansible.groups = {
      "leaf" => ["leaf-1","leaf-3","leaf-2","leaf-5","leaf-4","leaf-6",],
      "spine" => ["spine-1","spine-2",],
      "host" => ["server-4","server-2","server-3","server-1","server-6","server-5",],
      "client" => ["cli-1",],
      "og" => ["og-1", "og-3",],
      "network:children" => ["leaf","spine","edge",]
    }
  end

  config.vm.define 'spine-1' do |spine01|
    spine01.vm.box = default_box
    spine01.vm.boot_timeout = 600
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01l01',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01l02',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01l03',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01l04',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
		       virtualbox__intnet: 's01cli',
		       ip: '169.254.1.11', auto_config: false
    spine01.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
    end
  config.vbguest.auto_update = false
  end

  config.vm.define 'spine-2' do |spine02|
    spine02.vm.box = default_box
    spine02.vm.boot_timeout = 600
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02l01',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02l02',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02l03',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02l04',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
		       virtualbox__intnet: 's02cli',
		       ip: '169.254.1.11', auto_config: false
    spine02.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
    end
   config.vbguest.auto_update = false
  end

  config.vm.define 'leaf-1' do |leaf01|
    leaf01.vm.box = default_box
    leaf01.vm.network 'private_network',
                       virtualbox__intnet: 's01l01',
                       ip: '169.254.1.11', auto_config: false
    leaf01.vm.network 'private_network',
                       virtualbox__intnet: 's02l01',
                       ip: '169.254.1.11', auto_config: false
    leaf01.vm.network 'private_network',
                       virtualbox__intnet: 'l01l02',
                       ip: '169.254.1.11', auto_config: false
    leaf01.vm.network 'private_network',
                       virtualbox__intnet: 'l01og1',
                       ip: '169.254.1.11', auto_config: false
    leaf01.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
    end
  config.vbguest.auto_update = false
  end

  config.vm.define 'leaf-2' do |leaf02|
    leaf02.vm.box = default_box
    leaf02.vm.network 'private_network',
                       virtualbox__intnet: 's01l02',
                       ip: '169.254.1.11', auto_config: false
    leaf02.vm.network 'private_network',
                       virtualbox__intnet: 's02l02',
                       ip: '169.254.1.11', auto_config: false
    leaf02.vm.network 'private_network',
                       virtualbox__intnet: 'l01l02',
                       ip: '169.254.1.11', auto_config: false
    leaf02.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
    end
  config.vbguest.auto_update = false
  end
  
  config.vm.define 'leaf-3' do |leaf03|
    leaf03.vm.box = default_box
    leaf03.vm.network 'private_network',
                       virtualbox__intnet: 's01l03',
                       ip: '169.254.1.11', auto_config: false
    leaf03.vm.network 'private_network',
                       virtualbox__intnet: 's02l03',
                       ip: '169.254.1.11', auto_config: false
    leaf03.vm.network 'private_network',
                       virtualbox__intnet: 'l03l04',
                       ip: '169.254.1.11', auto_config: false
    leaf03.vm.network 'private_network',
                       virtualbox__intnet: 'l03og3',
                       ip: '169.254.1.11', auto_config: false
    leaf03.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
    end
  config.vbguest.auto_update = false
  end

  config.vm.define 'leaf-4' do |leaf04|
    leaf04.vm.box = default_box
    leaf04.vm.network 'private_network',
                       virtualbox__intnet: 's01l04',
                       ip: '169.254.1.11', auto_config: false
    leaf04.vm.network 'private_network',
                       virtualbox__intnet: 's02l04',
                       ip: '169.254.1.11', auto_config: false
    leaf04.vm.network 'private_network',
                       virtualbox__intnet: 'l03l04',
                       ip: '169.254.1.11', auto_config: false
    leaf04.vm.boot_timeout = 600
    leaf04.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
    end
  config.vbguest.auto_update = false
  end

  config.vm.define 'cli-1' do |cli1|
    cli1.vm.box = server_box
    cli1.vm.hostname = 'cli-1'
    cli1.disksize.size = "30GB"
    cli1.vm.synced_folder ".", "/vagrant", disabled: false
    if path_exists?($nbpath)
      cli1.vm.synced_folder $nbpath, "/NetBricks", disabled: false
    end
    if path_exists?($mgpath)
      cli1.vm.synced_folder $mgpath, "/MoonGen", disabled: false
    end
    cli1.vm.network 'private_network',
                       virtualbox__intnet: 's01cli',
                       ip: '10.0.251.3'
    cli1.vm.network 'private_network',
                       virtualbox__intnet: 's02cli',
                       ip: '10.0.252.3'
    cli1.vm.provider 'virtualbox' do |vb|
      vb.name = 'cli-1'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    end

    config.vbguest.auto_update = false
  end

  config.vm.define 'og-1' do |og1|
    og1.vm.box = server_box
    og1.vm.boot_timeout = 600
    og1.vm.hostname = 'og-1'
    og1.disksize.size = "30GB"
    og1.vm.synced_folder ".", "/vagrant", disabled: false
    if path_exists?($nbpath)
      og1.vm.synced_folder $nbpath, "/NetBricks", disabled: false
    end
    if path_exists?($mgpath)
      og1.vm.synced_folder $mgpath, "/MoonGen", disabled: false
    end
    og1_network = '10.0.101'
    og1_host = '2'
    og1_asn = '65001'
    og1.vm.network 'private_network',
                       virtualbox__intnet: 'l01og1',
                       ip: og1_network + '.' + og1_host
    og1.vm.network 'private_network',
                       virtualbox__intnet: 'og1priv',
                       ip: '192.168.0.' + og1_host
    og1.vm.provider 'virtualbox' do |vb|
      vb.name = 'og-1'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    end
    og1.vm.provision 'shell', privileged: true, path: 'og-setup.sh', args: [og1_network, og1_host, og1_asn]
									    
    config.vbguest.auto_update = false
  end

  config.vm.define 'og-3' do |og3|
    og3.vm.box = server_box
    og3.vm.hostname = 'og-3'
    og3.disksize.size = "30GB"
    og3.vm.synced_folder ".", "/vagrant", disabled: false
    if path_exists?($nbpath)
      og3.vm.synced_folder $nbpath, "/NetBricks", disabled: false
    end
    if path_exists?($mgpath)
      og3.vm.synced_folder $mgpath, "/MoonGen", disabled: false
    end
    og3_network = '10.0.102'
    og3_host = '4'
    og3_asn = '65003'
    og3.vm.network 'private_network',
                       virtualbox__intnet: 'l03og3',
                       ip: og3_network + '.' + og3_host
    og3.vm.network 'private_network',
                       virtualbox__intnet: 'og3priv',
                       ip: '192.168.0.' + og3_host
    og3.vm.provider 'virtualbox' do |vb|
      vb.name = 'og-3'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    end
    og3.vm.provision 'shell', privileged: true, path: 'og-setup.sh', args: [og3_network, og3_host, og3_asn]
    config.vbguest.auto_update = false
  end

end
