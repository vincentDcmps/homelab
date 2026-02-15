#!/bin/bash

# required env:
# - ARCH_MIRROR
# - ARCH_RELEASE
# - KEYMAP
# - LOCALE
# - TIMEZONE
#
# optional env
# - EXTRA_PACKAGES

set -euo pipefail

if [[ $PACKER_BUILDER_TYPE == "hcloud" ]]; then
  readonly ARCH_ISO="archlinux-bootstrap-${ARCH_RELEASE//-/.}-x86_64.tar.zst"

  # obtain arch tools
  curl --fail -o "${ARCH_ISO}"     "${ARCH_MIRROR}/iso/${ARCH_RELEASE//-/.}/${ARCH_ISO}"
  curl --fail -o "${ARCH_ISO}.sig" "${ARCH_MIRROR}/iso/${ARCH_RELEASE//-/.}/${ARCH_ISO}.sig"
  gpg --verify "./${ARCH_ISO}.sig" "./${ARCH_ISO}"
  tar --zstd -xvf "./${ARCH_ISO}"
  rm -f "./${ARCH_ISO}" # save ramfs memory

  # prepare mounts
  readonly iso='/root/root.x86_64'
  mount --bind "$iso" "$iso" # XXX arch-chroot needs / to be a mountpoint
  mount --bind /mnt "$iso/mnt"
  readonly DISK="sda"
  firsCommand="${iso}/bin/arch-chroot ${iso}"
else
  readonly DISK='vda'
  readonly iso=""
  firsCommand="sh"
fi
# install base
echo  " Installing base system...${firsCommand}"
$firsCommand <<EOF
set -euo pipefail
echo "toto"
# pacstrap
sed -i '1s|^|Server = ${ARCH_MIRROR}\/\$repo\/os\/\$arch\n|' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate archlinux
pacstrap  /mnt base linux grub nano btrfs-progs openssh curl jq python-yaml systemd-resolvconf  $EXTRA_PACKAGES

# fstab
genfstab -U /mnt > /mnt/etc/fstab
echo 'proc /proc proc defaults,hidepid=2 0 0' >> /mnt/etc/fstab
EOF

# configure base
"${iso}/bin/arch-chroot" /mnt <<EOF
set -euo pipefail

# time
systemctl enable systemd-timesyncd
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# locale
echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf
echo '${LOCALE}' > /etc/locale.gen
if [ "$LOCALE" != "en_US.UTF-8" ]; then
  echo 'en_US.UTF-8 UTF8' >> /etc/locale.gen
fi
locale-gen

# network
mkdir -p /root/.ssh/
systemctl enable systemd-networkd systemd-resolved sshd
cat > /etc/systemd/network/default.network <<EOF2
[Match]
Name=en*
[Network]
DHCP=yes
EOF2

# grub
mkinitcpio  -p linux
grub-install /dev/${DISK}
grub-mkconfig -o /boot/grub/grub.cfg 
# misc
systemctl set-default multi-user.target
useradd -m -s /bin/bash ansible
mkdir /home/ansible/.ssh
chown  -R ansible:ansible /home/ansible/.ssh
echo 'ansible ALL = (ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
echo '${SSH_PUBLIC_KEY}' >>  /home/ansible/.ssh/authorized_keys
echo 'archlinux' > /etc/hostname
EOF

if [[ $PACKER_BUILDER_TYPE == "hcloud" ]]; then
# hcloud
# these services were uploaded by packer beforehand
  usermod -L root
  "${iso}/bin/arch-chroot" /mnt <<EOF
for i in /etc/systemd/system/hcloud*.service; do
  systemctl enable "\$i"
done
EOF
else
  "${iso}/bin/arch-chroot" /mnt <<EOF
  systemctl enable firstboot.service
  rm /etc/machine-id
EOF
fi

ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
# clean up
rm /mnt/root/.bash_history
rm -r /mnt/var/cache/*
/usr/bin/umount "/mnt"
