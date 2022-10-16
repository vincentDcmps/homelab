# Homelab


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
  oscar[oscar]
  gerard[gerard]
  end
  subgraph Cloud
  merlin[merlin]
  end
  oscar <--lan--> gerard
  oscar <--wiregard--> merlin
  gerard <--wiregard--> merlin
  merlin <--> internet 
  
```
