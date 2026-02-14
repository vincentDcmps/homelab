terraform {

  required_providers {
     libvirt = {
      source = "dmacvicar/libvirt"
      version =  "~>0.9"
    }
  }
}

variable "hostname" {
  type    = string
  default = "archdev"
}
variable "networkname" {
  type    = string
  default = "default"
}
variable "memory" {
  type    = number
  default = 2048
}
variable "vcpu" {
  type    = number
  default = 2
}
variable "backing_store_path" {
  type    = string
}
variable "disk_size" {
  type    = number
  default = 20
}
variable "mac_address" {
  type    = string
}

resource "libvirt_cloudinit_disk" "init" {
  name      = "${var.hostname}-init"
  user_data = ""
  meta_data = var.hostname
}

resource "libvirt_volume" "cloudinit" {
  name   = "${var.hostname}-cidata.iso"
  pool   = "default"
  create={
    content = {
      url =libvirt_cloudinit_disk.init.path
    }
  }
  target=  {
    format = {
      type="iso"
    }
  }

}

resource "libvirt_volume" "volume" {
  name   = "${var.hostname}.qcow2"
  pool   = "default"
  capacity = var.disk_size * 1024 * 1024 * 1024
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
    path   = var.backing_store_path
    format =  {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "dev" {
  name   = var.hostname
  memory = var.memory
  memory_unit = "MB"
  vcpu   = var.vcpu
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
            file = libvirt_volume.volume.path
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
      },
      {
        source ={
          file= {
            file = libvirt_volume.cloudinit.path
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
            network=var.networkname
          }
        }
        mac = {
          address = var.mac_address
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


