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
resource "libvirt_cloudinit_disk" "init" {
  for_each=  {for vm in var.vms : vm.name => vm }
  name      = "${each.key}-init"
  user_data = ""
  meta_data = each.key
}

resource "libvirt_volume" "cloudinit" {
  for_each=  {for vm in var.vms : vm.name => vm }
  name   = "${each.key}-cidata.iso"
  pool   = "default"
  create={
    content = {
      url =libvirt_cloudinit_disk.init[each.key].path
    }
  }
  target=  {
    format = {
      type="iso"
    }
  }

}

resource "libvirt_volume" "volume" {
  for_each=  {for vm in var.vms : vm.name => vm }
  name   = "${each.key}.qcow2"
  pool   = "default"
  capacity = each.value.disk_size * 1024 * 1024 * 1024
  target ={
    format = {
      type = "qcow2"
    }
  }
  #create = {
  #  content = {
  #            url = "../../packer/output-archlinux-libvirtd/${tolist(fileset("../../packer/output-archlinux-libvirtd","*"))[0]}"
  #  }
  #}
  backing_store = {
    path   = libvirt_volume.base.id
    format =  {
      type = "qcow2"
    }
  }
}


resource "libvirt_domain" "dev" {
  for_each=  {for vm in var.vms : vm.name => vm }
  name   = each.key
  memory = each.value.memory
  memory_unit = "MB"
  vcpu   = each.value.vcpu
  type   = "kvm"
  running = true
  features = {
    acpi = "true"
    apic = {
    }
    vmport = {
      state  = "off"
    }
  }
  cpu  = {
    mode = "host-passthrough"
  }
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      {
        dev = "hd"
      },
      {
        dev = "network"
      }
    ]
  }
  devices = {
    channel = [
      {
        type = "unix"
        target = {
          type = "virtio"
          name = "org.qemu.guest_agent.0"
        }
        address = {
          type = "virtio-serial"
          controller = "0"
          bus = "0"
          port = "1"
        }
      },
      {
        type = "spicevmc"
        target = {
          type = "virtio"
          name = "com.redhat.spice.0"
        }
        address = {
          type = "virtio-serial"
          controller = "0"
          bus = "0"
          port = "2"
        }
      }
    ]
    disks = [
      {
        source = {
          file= {
            file = libvirt_volume.volume[each.key].path
          }
        }
        driver ={
          name = "qemu"
          type = "qcow2"
          cache = "none"
        }
        target = {
          dev = "sda"
          bus = "virtio"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source ={
          file= {
            file = libvirt_volume.cloudinit[each.key].path
          }
        }
        device ="cdrom"
        target = {
          dev = "hda"
          bus = "sata"
        }
      }
    ]
    interfaces = [
      {
        source = {
          network = {
            network=libvirt_network.homelab.name
          }
        }
        model = {
          type = "virtio"
        }
        wait_for_ip = {
          source = "lease"
        }
      }
    ]
    video = [
      {
        type = "virtio"
         heads = "1"
        primary = "yes"
        address = {
          type = "pci"
          domain = "0x0000"
          bus = "0x00"
          slot = "0x01"
          function = "0x0"
        }
      }
    ]
    graphics = [
      {
        spice = {
          autoport = "yes"
          image ={
            compression = "off"
          }
      }
    }
    ]
  }
}


