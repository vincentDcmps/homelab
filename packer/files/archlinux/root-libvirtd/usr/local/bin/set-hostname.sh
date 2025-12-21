#!/bin/sh
mount /dev/sr0 /var/run/mount
CDROM="/var/run/mount/meta-data"
systemd-machine-id-setup
if [ -f "$CDROM" ]; then
    NEW_HOSTNAME=$(cat "$CDROM")
    hostnamectl set-hostname "$NEW_HOSTNAME"
fi
# Supprimer le script pour ne pas le relancer
rm -f /usr/local/bin/set-hostname.sh
systemctl disable firstboot.service
umount /dev/sr0
systemctl restart systemd-networkd
