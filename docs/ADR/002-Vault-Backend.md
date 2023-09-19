# 002-Vault-Backend

## Status

## Context

Currently vault Backend is onboard in Consul KV
Hashicorp recommandation is to use integrated storage from vault cluster
This could remove consul dependancy on rebuild

## Decision

migrate to vault integrated storage

## Consequences

to do:

- [migration plan]("https://developer.hashicorp.com/vault/tutorials/raft/raft-migration")

1. basculer oscar,gerard et bleys and itegrated storage merlin restera en storage consul pendant l'opé avant décom
2. stoper le service vault sur oscar
3. lancer la commande de migration
4. joindre les autre node au cluster
5. décom vault sur merlin
6. adapter job backup

- [backup]("https://developer.hashicorp.com/vault/tutorials/standard-procedures/sop-backup")
