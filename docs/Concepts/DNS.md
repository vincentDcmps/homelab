# Architecture DNS

```mermaid
flowchart LR
  subgraph External
  externalRecursor[recursor]
  GandiDns[ hetzner ducamps.win]
  end
  subgraph Internal
  pihole[pihole]--ducamps.win-->NAS
  pihole--service.consul-->consul[consul cluster]
  pihole--->recursor
  recursor--service.consul-->consul
  DHCP --dynamic update--> NAS
  NAS
  recursor--ducamps.win-->NAS
  consul--service.consul--->consul
  clients--->pihole
  clients--->recursor
  end
  pihole --> externalRecursor
  recursor-->External
```

## Detail

Pihole container in nomad cluster is set as primary DNS as add blocker secondary DNS recursore is locate on gerard

DNS locate on NAS manage domain *ducamps.win* on local network each recursor forward each request on *ducamps.win* to this DNS.

Each DNS forward *service.consul* request to the consul cluster. 
Each consul node have a consul redirection in systemd-resolved to theire own consul client

a DHCP service is set to do dynamic update on NAS DNS on lease delivery

external recursor are set on pihole on cloudflare and FDN in case of recursors faillure
