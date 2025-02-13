#!/bin/bash

set -exo pipefail

# See the README-arista.git.md file for an explanation on why we
# need to do this.

# This script grabs the current metadata for arista.git, makes a trivial
# modification, and then undoes that modification. We do this because it
# will reset the last-modified timestamp on arista.git.

RPMD_URL="${RPMD_URL:-https://repometadata.infra.corp.arista.io}"

origbuf="$(mktemp)"
curl --fail-with-body "${RPMD_URL}/repos/arista" \
	| jq .Metadata \
	| jq 'del( .LastUpdated )' \
	| jq 'del( .obsoleteNamesTransitive )' \
	> "${origbuf}"

modbuf="$(mktemp)"
jq '.Labels.barney_ops_force_refresh="true"' < "${origbuf}" > "${modbuf}"

jq -c -r '{ "Repometadata": [ . ] }' "${modbuf}"  \
	| curl --fail-with-body --data-binary @- "${RPMD_URL}/repos/" -X PUT

jq -c -r '{ "Repometadata": [ . ] }' "${origbuf}"  \
	| curl --fail-with-body --data-binary @- "${RPMD_URL}/repos/" -X PUT
