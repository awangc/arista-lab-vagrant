# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
VAGRANTFILE_API_VERSION = "2"

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

dc1_network = '10.0.153'
dc2_network = '10.0.253'
dc1_asn = '65002'
dc2_asn = '65003'
ext1_network = '10.0.151'
ext2_network = '10.0.252'
dc1_anycast_subnet = '192.168.1'
dc2_anycast_subnet = '192.168.2'

bgp_host = '11'
og_host = '12'
client_host = '3'
app_host = '13'
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./helper_scripts/empty_playbook.yml"
    ansible.groups = {
      "spine" => ["spine-1","spine-2",],
      "bgp" => ["bgp-1","bgp-2",],
      "client" => ["cli-1","cli-2"],
      "og" => ["og-1", "og-2",],
      "network:children" => ["spine",]
    }
  end

  # for spine and leaf devices we only create the appropriate number of
  # interfaces, they will be configured via ansible/site.yml

  # each of the 2 spines has a direct port connecting to each of the 4 leaves,
  # these connections use prefix 10.0.255.x (split into multiple /30 subnets)
  #
  # for spine-{1,2} device, the subnet we are setting to connect to the client is
  # 10.0.25{1,2}.0/24 (see ansible/host_vars/spine-{1,2}.yml, under "interfaces",
  # the interface with alias "uplink-cli-{1,2}).
  #
  # for leaf-{1,3} device, the subnet we are setting to connect to the og-{1,3}
  # is the VLAN {101,102} with subnets 10.0.10{1,2}.0/24 (see ansible/host_vars/leaf-{1,3}.yml)
  #
  # we are using subnet 192.168.0.0/16 for anycasting. Each of the og-{1,3} binds
  # to 192.168.0.{2,4} and they advertise route 192.168.0.0/16 via BGP to their peers
  # (leaf-{1,3}).
  #
  # this setup means:
  #   - client devices must set as default gateway to route 192.168.0.0/16 the spine
  #     devices they're connected to (so for cli-1: "ip route add 192.168.0.0/16 via 10.0.251.2 dev enp0s8")
  #   - og servers must set the leaf devices they are connected to as default gateways for
  #     any subnets they want to reach, e.g., spine (10.0.255.0/24) and client networks
  #     (10.0.251.0/24).
  #   - og servers must have reverse path filtering disabled, ip forwarding enabled.

  config.vm.define 'spine-1' do |spine01|
    spine01.vm.box = default_box
    spine01.vm.boot_timeout = 600
    spine01.vm.network 'private_network',
		       virtualbox__intnet: 's01cli1',
		       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
		       virtualbox__intnet: 's01s02',
		       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01bgp1',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
                       virtualbox__intnet: 's01og1',
                       ip: '169.254.1.11', auto_config: false
    spine01.vm.network 'private_network',
		       virtualbox__intnet: 's01app1',
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
		       virtualbox__intnet: 's02cli2',
		       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
		       virtualbox__intnet: 's01s02',
		       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02bgp2',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02og2',
                       ip: '169.254.1.11', auto_config: false
    spine02.vm.network 'private_network',
                       virtualbox__intnet: 's02app2',
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

  config.vm.define 'cli-1' do |cli1|
    cli1.vm.box = server_box
    cli1.vm.hostname = 'cli-1'
    cli1.disksize.size = "30GB"
    cli1.vm.synced_folder ".", "/vagrant", disabled: false
    # interface 1 seems to map to enp0s3 (the one interface the guest uses to
    # talk to the host), additional interfaces bind to enp0s(6 + interface number)
    # so interface 2 would be bound to 10.0.251.3 below and mapped to enp0s8,
    # currently cli-1 is connected to spine-1 
    cli1.vm.network 'private_network',
                       virtualbox__intnet: 's01cli1',
                       ip: ext1_network + '.' + client_host
    cli1.vm.provider 'virtualbox' do |vb|
      vb.name = 'cli-1'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
    end

    config.vbguest.auto_update = false
  end


  config.vm.define 'cli-2' do |cli2|
    cli2.vm.box = server_box
    cli2.vm.hostname = 'cli-2'
    cli2.disksize.size = "30GB"
    cli2.vm.synced_folder ".", "/vagrant", disabled: false
    # interface 1 seems to map to enp0s3 (the one interface the guest uses to
    # talk to the host), additional interfaces bind to enp0s(6 + interface number)
    # so interface 2 would be bound to 10.0.252.3 below and mapped to enp0s8,
    # currently cli-2 is connected to spine-2
    cli2.vm.network 'private_network',
                       virtualbox__intnet: 's02cli2',
                       ip: ext2_network + '.' + client_host 
    cli2.vm.provider 'virtualbox' do |vb|
      vb.name = 'cli-2'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
    end

    config.vbguest.auto_update = false
  end

  config.vm.define 'bgp-1' do |bgp1|
    bgp1.vm.box = server_box
    bgp1.vm.hostname = 'bgp-1'
    bgp1.vm.synced_folder ".", "/vagrant", disabled: false
    bgp1.vm.network 'private_network',
                       virtualbox__intnet: 's01bgp1',
                       ip: dc1_network + '.' + bgp_host
    bgp1.vm.network 'private_network',
                       virtualbox__intnet: 'bgp1og1',
                       ip: dc1_anycast_subnet + '.' + bgp_host
    bgp1.vm.provider 'virtualbox' do |vb|
      vb.name = 'bgp-1'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    end
    bgp1.vm.provision 'shell', privileged: true, path: 'bgp-setup.sh', args: [dc1_network, bgp_host, dc1_asn]
    config.vbguest.auto_update = false
  end

  config.vm.define 'bgp-2' do |bgp2|
    bgp2.vm.box = server_box
    bgp2.vm.hostname = 'bgp-2'
    bgp2.vm.synced_folder ".", "/vagrant", disabled: false
    bgp2.vm.network 'private_network',
                       virtualbox__intnet: 's02bgp2',
                       ip: dc2_network + '.' + bgp_host
    bgp2.vm.network 'private_network',
                       virtualbox__intnet: 'bgp2og2',
                       ip: dc2_anycast_subnet + '.' + bgp_host
    bgp2.vm.provider 'virtualbox' do |vb|
      vb.name = 'bgp-2'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    end
    bgp2.vm.provision 'shell', privileged: true, path: 'bgp-setup.sh', args: [dc2_network, bgp_host, dc2_asn]
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
    og1_network = dc1_network
    og1_host = og_host
    og1_asn = dc1_asn
    # Create a private network, which allows host-only access to the machine using a
    # specific IP. This option is needed because DPDK takes over the NIC.
    og1.vm.network "private_network", ip: "10.1.2.2", mac: "BADCAFEBEEF1", nic_type: "virtio"
    og1.vm.network "private_network", ip: "10.1.2.3", mac: "BADCAFEBEEF2", nic_type: "virtio"
    og1.vm.network 'private_network',
                       virtualbox__intnet: 's01og1',
                       ip: og1_network + '.' + og1_host
    og1.vm.network 'private_network',
                       virtualbox__intnet: 'bgp1og1',
                       ip: dc1_anycast_subnet + '.' + og1_host
    og1.vm.provision 'shell', privileged: true, path: 'og-setup.sh'

    # Pull and run (then remove) our image in order to do the devbind
    og1 .vm.provision "docker" do |d|
      d.pull_images "#{$dproject}/#{$dimage}:#{$dtag}"
      d.run "#{$dproject}/#{$dimage}:#{$dtag}",
          auto_assign_name: false,
          args: %W(--name=#{$dimage}
                   --rm
                   --privileged
                   --pid=host
                   --network=host
                   -v /lib/modules:/lib/modules
                   -v /usr/src:/usr/src
                   -v /sys/bus/pci/drivers:/sys/bus/pci/drivers
                   -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages
                   -v /sys/devices/system/node:/sys/devices/system/node
                   -v /sbin/modinfo:/sbin/modinfo
                   -v /bin/kmod:/bin/kmod
                   -v /sbin/lsmod:/sbin/lsmod
                   -v /dev:/dev
                   -v /mnt/huge:/mnt/huge
                   -v /var/run:/var/run).join(" "),
          restart: "no",
          daemonize: true,
          cmd: "/bin/bash -c '/dpdk/usertools/dpdk-devbind.py --force -b #{$dpdk_driver} #{$dpdk_devices}'"
    end

    og1.vm.provider 'virtualbox' do |vb|
      vb.name = 'og-1'
      vb.memory = 4096
      vb.cpus = 4
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
      # Configure VirtualBox to enable passthrough of SSE 4.1 and SSE 4.2 instructions,
      # according to this: https://www.virtualbox.org/manual/ch09.html#sse412passthrough
      # This step is fundamental otherwise DPDK won't build. It is possible to verify in
      # the guest OS that these changes took effect by running `cat /proc/cpuinfo` and
      # checking that `sse4_1` and `sse4_2` are listed among the CPU flags.
      vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
      vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
    end
    og1.vm.provision 'shell', privileged: true, path: 'og-setup.sh', args: [og1_network, og1_host, og1_asn]
    config.vbguest.auto_update = false
  end

  config.vm.define 'og-2' do |og2|
    og2.vm.box = server_box
    og2.vm.boot_timeout = 600
    og2.vm.hostname = 'og-2'
    og2.disksize.size = "30GB"
    og2.vm.synced_folder ".", "/vagrant", disabled: false
    if path_exists?($nbpath)
      og2.vm.synced_folder $nbpath, "/NetBricks", disabled: false
    end
    if path_exists?($mgpath)
      og2.vm.synced_folder $mgpath, "/MoonGen", disabled: false
    end
    og2_network = dc2_network
    og2_host = og_host
    og2_asn = dc2_asn
    # Create a private network, which allows host-only access to the machine using a
    # specific IP. This option is needed because DPDK takes over the NIC.
    og2.vm.network "private_network", ip: "10.1.2.4", mac: "BADCAFEBEEF3", nic_type: "virtio"
    og2.vm.network "private_network", ip: "10.1.2.5", mac: "BADCAFEBEEF4", nic_type: "virtio"
    og2.vm.network 'private_network',
                       virtualbox__intnet: 's02og2',
                       ip: og2_network + '.' + og2_host
    og2.vm.network 'private_network',
                       virtualbox__intnet: 'bgp2og2',
                       ip: dc2_anycast_subnet + '.' + og2_host
    og2.vm.provision 'shell', privileged: true, path: 'og-setup.sh'

    # Pull and run (then remove) our image in order to do the devbind
    og2 .vm.provision "docker" do |d|
      d.pull_images "#{$dproject}/#{$dimage}:#{$dtag}"
      d.run "#{$dproject}/#{$dimage}:#{$dtag}",
          auto_assign_name: false,
          args: %W(--name=#{$dimage}
                   --rm
                   --privileged
                   --pid=host
                   --network=host
                   -v /lib/modules:/lib/modules
                   -v /usr/src:/usr/src
                   -v /sys/bus/pci/drivers:/sys/bus/pci/drivers
                   -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages
                   -v /sys/devices/system/node:/sys/devices/system/node
                   -v /sbin/modinfo:/sbin/modinfo
                   -v /bin/kmod:/bin/kmod
                   -v /sbin/lsmod:/sbin/lsmod
                   -v /dev:/dev
                   -v /mnt/huge:/mnt/huge
                   -v /var/run:/var/run).join(" "),
          restart: "no",
          daemonize: true,
          cmd: "/bin/bash -c '/dpdk/usertools/dpdk-devbind.py --force -b #{$dpdk_driver} #{$dpdk_devices}'"
    end

    og2.vm.provider 'virtualbox' do |vb|
      vb.name = 'og-2'
      vb.memory = 4096
      vb.cpus = 4
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
      vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
      # Configure VirtualBox to enable passthrough of SSE 4.1 and SSE 4.2 instructions,
      # according to this: https://www.virtualbox.org/manual/ch09.html#sse412passthrough
      # This step is fundamental otherwise DPDK won't build. It is possible to verify in
      # the guest OS that these changes took effect by running `cat /proc/cpuinfo` and
      # checking that `sse4_1` and `sse4_2` are listed among the CPU flags.
      vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
      vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
    end

    config.vbguest.auto_update = false
  end


  config.vm.define 'app-1' do |app1|
    app1.vm.box = server_box
    app1.vm.hostname = 'app-1'
    app1.vm.synced_folder ".", "/vagrant", disabled: false
    app1.vm.network 'private_network',
                       virtualbox__intnet: 's01app1',
                       ip: dc1_network + '.' + app_host
    app1.vm.provider 'virtualbox' do |vb|
      vb.name = 'app-1'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
    end
#    app1.vm.provision 'shell', privileged: true, path: 'app-setup.sh', args: []
    config.vbguest.auto_update = false
  end

  config.vm.define 'app-2' do |app2|
    app2.vm.box = server_box
    app2.vm.hostname = 'app-2'
    app2.vm.synced_folder ".", "/vagrant", disabled: false
    app2.vm.network 'private_network',
                       virtualbox__intnet: 's02app2',
                       ip: dc2_network + '.' + app_host
    app2.vm.provider 'virtualbox' do |vb|
      vb.name = 'app-2'
      vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
    end
#    app1.vm.provision 'shell', privileged: true, path: 'app-setup.sh', args: []
    config.vbguest.auto_update = false
  end
end
