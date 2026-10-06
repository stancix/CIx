#!/usr/local/bin/bash

unset CIX_SRC_COMMIT

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then
  echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--src_commit')
   if [[ -v CIX_SRC_COMMIT ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_SRC_COMMIT="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh CIX_SRC_COMMIT

git -C "${CIX_WORKDIR}" merge --no-ff --no-commit "${CIX_SRC_COMMIT}" 2> /dev/null \
 || . $checks/fail.sh 'Git merge error!'

git -C "${CIX_WORKDIR}" add . \
 || . $checks/fail.sh 'Git add error!'
