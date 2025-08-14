# 001 CITool

## Status

Accepted

## Context

Currently this infrastructure use DRONECI to perform some tests and build.

DRONECI have changed licence some time ago so we need to switch on another project to keep on open source licence.

two main choise have been study

### Woodpecker

DRONECI fork this are pretty the same feature. advantage will be an easier migration due to compatibility of configuration.

Woodpecker don't mange vault secret whereas DRONECI.

### Gitea Action

CI Solution integrated in gitea this permit to have all the information in the same interface and to have 1 less service to deploy.

Vault password is not manage too.

bigger community because highly compatible with github action.

_Act software be able to test locally workfow easier_

## Decision

Decision is to implement Gitea Action due to the hightest compatibility with github action. this could be usefull for my work.
morever To have all the information bring in Gitea can simplify a litle bit the infrastructure

## Consequences

we have to migrate all drone configuration file to GITEA Action
