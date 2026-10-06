#!/usr/local/bin/bash

unset CIX_SRC_COMMIT

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--src_commit') [[ -v CIX_SRC_COMMIT ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_SRC_COMMIT="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_SRC_COMMIT

git -C "${CIX_WORKDIR}" merge --no-ff --no-commit "${CIX_SRC_COMMIT}" 2> /dev/null \
 || . $checks/fail.sh 'Git merge error!'

git -C "${CIX_WORKDIR}" add . \
 || . $checks/fail.sh 'Git add error!'
