#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

git push --follow-tags \
 || . $checks/fail.sh 'Push error!'

CIX_RESULT_COMMIT="$(git rev-parse HEAD)" \
 || . $checks/fail.sh 'Get commit SHA error!'

SUBJECT="${CIX_SHARED}/gh_commit.json"

. $ghx/commit.sh "${ACTUAL_REP_OWNER}" "${ACTUAL_REP_NAME}" "${CIX_RESULT_COMMIT}" "${SUBJECT}"
