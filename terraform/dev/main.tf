terraform {

  required_providers {
     libvirt = {
      source = "dmacvicar/libvirt"
      version =  "~>0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "homelab" {
  name = "homelab"
  autostart = true
  bridge =  {
    name = "homelab_dev"
  }
  forward = {
    mode = "nat"
  }
  dns = {
    enable = "yes"

  }
  domain = {
    name = "lan.ducamps.dev"
  }
  ips  = [{
    address= "192.168.2.1"
    prefix =  "24"
    dhcp = {
      ranges= [{
        start = "192.168.2.2"
        end   = "192.168.2.254"
       },
      ]
    }
  }]
}
resource "libvirt_volume" "base" {
    name   = "arch_base.qcow2"
    pool   = "default"
    create = {
        content = {
              url = "../../packer/output-archlinux-libvirtd/${tolist(fileset("../../packer/output-archlinux-libvirtd","*"))[0]}"
                    # or: url = "file:///path/to/local/image.qcow2"
        }
    }
}

module "vm" {
  source = "./vm"
  for_each=  {for vm in var.vms : vm.name => vm }
  hostname = each.key
  disk_size = each.value.disk_size
  networkname = libvirt_network.homelab.name
  memory = each.value.memory
  vcpu = each.value.vcpu
  backing_store_path = libvirt_volume.base.path
}
