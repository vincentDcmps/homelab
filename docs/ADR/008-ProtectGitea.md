# 008 Protect Gitea Instance

## Status

Accepted

## Context

Gitea instance is crawled several time by days by AI and hacker loocking for password this cause overal consomation of CPU and security risk

## Decision

We will implement [anubis](https://github.com/TecharoHQ/anubis) to Protect Gitea

## Consequences

to have only one anubis instance running we will redirect all gitea traffic throught local reverse proxy.

To avoid this we have two solution:

- we could implement in future two anubis instance for gitea to keep separation beetween local and external request.
- currently local and external proxy are configure by same tags we could distinct configuration beetween both reverse proxy bu need to modify all site configuration.
