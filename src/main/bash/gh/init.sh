#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then
  echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--rep_owner')
   if [[ -v CIX_REP_OWNER ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name')
   if [[ -v CIX_REP_NAME ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_REP_NAME="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME

VCS_URL="https://github.com/${CIX_REP_OWNER}/${CIX_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $checks/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'
