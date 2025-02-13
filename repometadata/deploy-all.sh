#!/bin/bash

set -exo pipefail

for i in *.json; do
  ./deploy-one.sh "${i}"
done

./bump-arista-timestamp.sh
