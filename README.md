# Homelab

This repository contain my homelab Infrastructure As Code

this Homelab is build over Hashicorp software:

- Nomad
- Consul
- Vault

## Rebuild 
to rebuild from scratch ansible need a vault server up and unseal
you can rebuild a standalone vault server with a consul database snaphot with

```
make vault-dev FILE=./yourconsulsnaphot.snap
```



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
