# Mailserver

## Status

done

## Context

Gandi free email will become a pay service in 2 month.

In this condition it will be interesting to study selfhosted mail solution.

### domain name

do I take advantage of this to change domaine name:

Pro:

- could test more easy
- could redirect old domain name to new one untile end of gandi domain (2026)
- get a more "normal" extention

con:

- need to progresively update every personal account

### Container localisation

on hetzner:

- need to increase memory

on homelab:

- need to redirect all serveur flux to hetzner to be sure to be sure that mail will be send with hetzner IP (control PTR on this IP)
- hetzner will be too a SPOF

### software choose

mail server will run in nomad cluster.

docker-mailserver -> 1 container
mailu

## Decision

we will switch to another domain name on [bookmyname](https://www.bookmyname.com/): ducamps.eu""
docker-mailserver will be more easier to configure because only one container to migrate to nomad
for begining container will be launch on hetzner

## Consequences

- need to buy a new domaine name and configure DNS (done)
- inprove memory on corwin (done)
