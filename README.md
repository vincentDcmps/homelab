# Homelab

This repository contain my homelab Infrastructure As Code

this Homelab is build over Hashicorp software stack:

- Nomad
- Consul
- Vault

## Dev

dev stack is build over vagrant box with libvirt provider

curently need to have vault and ldap production up to be correctly provision

to launch dev stack provissionning :

```sh
make create-dev
```

## Rebuild

## Architecture

```mermaid
flowchart LR
  subgraph Home
  bleys[bleys]
  oscar[oscar]
  gerard[gerard]
  LAN
  NAS
  end
  subgraph Cloud
  corwin[corwin]
  end
  LAN--main road--ooscar
  LAN --- bleys
  LAN --- gerard
  LAN --- NAS
  bleys <--wireguard--> corwin
  oscar <--wiregard--> corwin
  gerard <--wiregard--> corwin
  corwin <--> internet 
  
```
