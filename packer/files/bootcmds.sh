#!/bin/bash
set -o xtrace

echo 'root:root' | chpasswd
systemctl start sshd

