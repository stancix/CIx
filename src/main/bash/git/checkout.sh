#!/usr/local/bin/bash

if [[ $# -ne 2 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

CIX_SRC_COMMIT="$1"
CIX_DST_BRANCH="$2"

. $checks/strings/require.sh CIX_SRC_COMMIT CIX_DST_BRANCH

git -C "${CIX_WORKDIR}" fetch origin "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${CIX_SRC_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${CIX_DST_BRANCH}\" error!"
