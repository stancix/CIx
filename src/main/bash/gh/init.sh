#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 2 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME

VCS_URL="https://github.com/${CIX_REP_OWNER}/${CIX_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $checks/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'
