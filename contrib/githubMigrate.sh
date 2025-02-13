#!/bin/sh

set -ex

gerritBase=https://horseland-gerrit.infra.corp.arista.io
project=$1
org=$2
if [ $# -gt 2 ]; then
    repo=$3
else
    repo=$project
fi
if [ -z "$GITHUB_USER" ]; then
    echo "Must specify GITHUB_USER in the environment"
    exit 1
fi
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Must specify GITHUB_TOKEN in the environment.  The token must have the repo and workflow scopes."
    exit 1
fi
if [ -z "$GERRIT_USER" ]; then
    export GERRIT_USER=$(id -n -u)
fi
if [ -z "$GERRIT_TOKEN" ]; then
    echo "Must specify GERRIT_TOKEN in the environment."
    exit 1
fi

gerritInfo=$(curl -Sf $gerritBase/projects/$project | tail -n 1)
description=$(echo $gerritInfo | jq -r .description)
curl -o /dev/null -X POST -Sf https://api.github.com/orgs/$org/repos -H 'Accept: application/vnd.github.v3+json' \
     -u $GITHUB_USER:$GITHUB_TOKEN --data "{\"name\":\"$repo\",\"description\":\"$description\",\"private\":\"true\"}" \
    || true # ignore errors because repo may already exist from prior run
githubInfo=$(curl -X GET -Sf https://api.github.com/repos/$org/$repo -H 'Accept: application/vnd.github.v3+json' -u $GITHUB_USER:$GITHUB_TOKEN)
githubPushURL=$(echo $githubInfo | jq -r .clone_url)

if [ ! -d $project ]; then
    git clone $gerritBase/a/$project
fi
cd $project
git remote remove github 2>/dev/null || true  # my kingdom for idempotency
git remote add github $githubPushURL

# Move over the meta.yaml and set the epoch to 1
if [ ! -f meta.yaml ]; then
   git fetch origin meta/config
   git checkout FETCH_HEAD meta.yaml
   git mv meta.yaml .
fi
yq -i eval '.epoch=1' meta.yaml
yq -i eval '.x-github-bridge.reviews[0].image="test"' meta.yaml
yq -i eval '.x-github-bridge.reviews[0].events[0].type="pull_request"' meta.yaml
yq -i eval '.x-github-bridge.reviews[0].events[1].type="push"' meta.yaml
yq -i eval '.x-github-bridge.reviews[0].events[1].branch-re="^main$"' meta.yaml
if [ -n "$(git diff meta.yaml)" ]; then
    git add meta.yaml
    git commit -m "Added meta.yaml"
else
    : # no changes
fi

# Now push
git push github

# Don't forget the notes
if ! git fetch origin refs/notes/barney:refs/notes/barney; then
    git notes --ref=barney add -m '{}'
fi
git push github refs/notes/barney:refs/notes/barney

# Update the description to reflect that it moved.
curl -H 'Content-Type: application/json' -u $GERRIT_USER:$GERRIT_TOKEN -Sf -X PUT $gerritBase/a/projects/$project/description --data "{\"description\":\"FROZEN.  Development moved to $githubPushURL.\n$description\",\"commit_message\":\"migration\"}"

# Set the old repo to READ_ONLY
curl -H 'Content-Type: application/json' -u $GERRIT_USER:$GERRIT_TOKEN -Sf -X PUT $gerritBase/a/projects/$project/config --data '{"state":"READ_ONLY"}'
