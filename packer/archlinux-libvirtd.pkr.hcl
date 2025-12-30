variable "extra-packages" {
  type    = list(string)
  default = ["python", "sudo", "inetutils", "zsh"]
}


variable "system-keymap" {
  type    = string
  default = "fr"
}

variable "system-locale" {
  type    = string
  default = "fr_FR.UTF-8"
}

variable "system-timezone" {
  type    = string
  default = "UTC"
}

variable "archmirror" {
  type    = string
  default = "https://arch.ducamps.eu"
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

locals {
  arch-release = "${legacy_isotime("2006.01")}.01"
  build-id     = "${uuidv4()}"
  sshkey       = file(var.ssh_public_key_path)
}
packer {
  required_plugins {
    quemu = {
      version = "~>  1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}
source "qemu" "archlinux" {
  iso_url          = "https://mirror.rackspace.com/archlinux/iso/${local.arch-release}/archlinux-${local.arch-release}-x86_64.iso"
  iso_checksum     = "file:https://mirror.rackspace.com/archlinux/iso/${local.arch-release}/sha256sums.txt"
  output_directory = "output-archlinux-libvirtd"
  vm_name          = "archlinux-${local.build-id}"
  disk_size        = "20480"
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = "."
  communicator     = "ssh"
  ssh_username     = "root"
  ssh_password     = "root"
  boot_wait        = "3s"
  headless         = true
  cpus             = 1
  memory           = 1024



  boot_command = [
    "<enter><wait10><wait10><wait10><wait10><wait10>",
    "curl -v 'http://{{ .HTTPIP }}:{{ .HTTPPort }}/files/bootcmds.sh'|bash <enter>",
  ]
}
build {
  sources = ["source.qemu.archlinux"]

  provisioner "shell" {
    script           = "files/filesystem.sh"
    environment_vars = ["LABEL=${local.build-id}"]
  }

  provisioner "file" {
    destination = "/tmp/key-${local.build-id}.gpg"
    source      = "files/archlinux/key.gpg"
  }
  provisioner "file" {
    destination = "/mnt/"
    source      = "files/archlinux/root-libvirtd/"
  }
  provisioner "shell" {
    inline = [
      "gpg --batch --import /tmp/key-${local.build-id}.gpg",
    ]
  }

  provisioner "shell" {
    script = "files/archlinux/install.sh"
    environment_vars = [
      "ARCH_MIRROR=${var.archmirror}",
      "ARCH_RELEASE=${local.arch-release}",
      "EXTRA_PACKAGES=${join(" ", var.extra-packages)}",
      "KEYMAP=${var.system-keymap}",
      "LOCALE=${var.system-locale}",
      "TIMEZONE=${var.system-timezone}",
      "SSH_PUBLIC_KEY=${local.sshkey}",
    ]
  }
}
