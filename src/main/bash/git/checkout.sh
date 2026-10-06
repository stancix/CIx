#!/usr/local/bin/bash

unset CIX_SRC_COMMIT
unset CIX_DST_BRANCH

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--src_commit') [[ -v CIX_SRC_COMMIT ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_SRC_COMMIT="$2"; shift 2;;
  '--dst_branch') [[ -v CIX_DST_BRANCH ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_DST_BRANCH="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_SRC_COMMIT CIX_DST_BRANCH

git -C "${CIX_WORKDIR}" fetch origin "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${CIX_SRC_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${CIX_DST_BRANCH}\" error!"
