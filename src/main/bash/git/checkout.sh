#!/usr/local/bin/bash

unset CIX_SRC_COMMIT
unset CIX_DST_BRANCH

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then
  echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--src_commit')
   if [[ -v CIX_SRC_COMMIT ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_SRC_COMMIT="$2"; shift 2;;
  '--dst_branch')
   if [[ -v CIX_DST_BRANCH ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_DST_BRANCH="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh CIX_SRC_COMMIT CIX_DST_BRANCH

git -C "${CIX_WORKDIR}" fetch origin "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${CIX_SRC_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${CIX_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${CIX_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${CIX_DST_BRANCH}\" error!"
