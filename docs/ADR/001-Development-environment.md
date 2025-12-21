# 001  Development environment

## Status

Accepted

## Context

we need to create a virtual cluster to do test without impact on production.

### Virtualisation or Container

Virtualisation provide better isolation but must ressource are needed.  
Container able to create more item without consum as resource than virtual machine.

### Creation Wrapper

Vagrant is good top manage virtual machine but not a lot of LXC box availlable, Vagant van be use with other configuration manager than ansible.
Molecule can manage molecule with plugins molecule-LXD. molecule is ansible exclusive solution

## Decision

we will use container instead VM for the resource consumption avantage.

Molecule wrapper will be use  because all our configuration is already provide by ansible and we can have a better choise of container with molecule than vagrant.

25/08/2023

some issue are meet with lxc (share kernel, privilege, plugin not maintain)
I have increase RAM on my computer so I can switch to virtual machine for the dev env
instead to build vagrant VM in a molecule playbooke we only use a vagrant file to avoid toi many overlay  to maintain.

## Consequences

migrate molecule provissioning on dedicated vagrant file


# Vagrant obsolecence

##  Context

Vagrant is  natively build  for virtualbox we need to use libvirt plugin to  use qemu provider.
Morever I meet often some issue with plugins on archlinux update.
I would like migrate my dev workspace creation to terraform which is more generic and more maintain than vagrant.

##  Decision

Migrate dev workspace creation to terraform with libvirt provider.

## Consequences

Need to create a qemu archlinux image to provision machine and deploy ansible role on it without manual action replacing vagrant box download.
This image will be create with packer like hetzner production image.
with that I will be autonome for image update.

