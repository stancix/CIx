#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 2 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME

git -C "${CIX_WORKDIR}" push --follow-tags \
 || . $checks/fail.sh 'Push error!'

CIX_RESULT_COMMIT="$(git -C "${CIX_WORKDIR}" rev-parse HEAD)" \
 || . $checks/fail.sh 'Get commit SHA error!'

SUBJECT="${CIX_SHARED}/gh_commit.json"

. $ghx/commit.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_RESULT_COMMIT}" "${SUBJECT}"
