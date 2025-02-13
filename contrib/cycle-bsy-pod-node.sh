#!/bin/bash

set -exo pipefail

pod="${1}"

node="$(kubectl -n barney get pod ${1} -o json | jq -r .spec.nodeName)"

kubectl drain ${node} --ignore-daemonsets --delete-emptydir-data

ssh core@${node} -- sudo shutdown -r now

kubectl uncordon ${node}
