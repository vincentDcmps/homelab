# homelab


## rebuild 
to rebuild from scratch ansible need a vault server up and unseal
you can rebuild a standalone vault srver with a consul database snaphot with

```
make vault-dev FILE=./yourconsulsnaphot.snap
```



## Architecture

```mermaid
flowchart LR
    subgraph Home
    oscar[oscar]
    gerard[gerard]
    local[lan]
    end
    subgraph Cloud
    merlin[merlin]
    end
  local[lan] <--> oscar
  oscar <--> merlin
  gerard <--> merlin
  merlin <--> internet 
  
```
