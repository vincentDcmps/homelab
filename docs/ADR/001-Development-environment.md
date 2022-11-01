# 001  Development environment

## Status

Accepted

## Context

we need to create a virtual cluster to do test without impact on production 
diferent way:

### Virtualisation or Container

Virtualisation provide better isolation but must ressource are needed.  
Container able to create more item without consum as resource than virtual machine.


### Creation Wrapper

Vagrant is good top manage virtual machine but not a lot of LXC box availlable, Vagant van be use with other configuration manager than ansible.
Molecule can manage molecule with plugins molecule-LXD. molecule is ansible exclusive solution

## Decision

we will use container instead VM for the resource consumption avantage.

Molecule wrapper will be use  because all our configuration is already provide by ansible and we can have a better choise of container with molecule than vagrant.

## Consequences

Need to create dev env other an LXD server.

