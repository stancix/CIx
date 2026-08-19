#!/usr/local/bin/bash

if [[ $# -ne 2 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

CIX_REP_OWNER="$1"
CIX_REP_NAME="$1"

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME VCS_SRC_COMMIT VCS_DST_BRANCH

VCS_URL="https://github.com/${CIX_REP_OWNER}/${CIX_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $checks/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'

git -C "${CIX_WORKDIR}" fetch origin "${VCS_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${VCS_SRC_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${VCS_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${VCS_DST_BRANCH}\" error!"
