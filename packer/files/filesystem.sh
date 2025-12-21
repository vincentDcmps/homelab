#!/bin/bash

set -euo pipefail

if [[ $PACKER_BUILDER_TYPE == "qemu" ]]; then
  DISK='vda'
else
  DISK='sda'
fi
# required env
# - LABEL filestystem label

# partitions
dd if=/dev/zero of=/dev/${DISK} bs=1MiB count=1 status=none
xargs -L1 parted --script /dev/${DISK} -- <<EOF
mklabel msdos
mkpart primary linux-swap 1MiB 2GiB
mkpart primary btrfs 2GiB 100%
set 1 boot on
EOF

# filesystems
mkswap -L swap /dev/${DISK}1
swapon /dev/${DISK}1
mkfs.btrfs --force --label "${LABEL}" /dev/${DISK}2
mount -o compress=lzo,commit=90,autodefrag /dev/${DISK}2 /mnt
