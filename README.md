# barney-ops

This repository contains ops tools and definitions for the barney ecosystem, _as used at Arista_.

There are no stability guarantees, and the contents of this repo is highly implementation-dependent.

## Structure

* contrib: various scripts to help with troubleshooting issues on a barney cluster
* helm: ArgoCD helm chart for deploying barney services on multiple clusters

## Dev deployments

The main branch of the barney-ops repo is meant for production deployments only.
For testing structural changes to the argocd applications and staging changes to services, please
use the dev branch of barney-ops, which targets its own dedicated argocd dev deployment.
