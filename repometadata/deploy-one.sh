#!/bin/bash

set -exo pipefail

RPMD_URL="${RPMD_URL:-https://repometadata.infra.corp.arista.io}"

jq -c -r '{ "Repometadata": [ .Labels["repometadata.source.repo"] = "code.arista.io/infra/barney/barney-ops" ] }' "${1}"  \
	 | curl --fail-with-body --data-binary @- "${RPMD_URL}/repos/" -X PUT
