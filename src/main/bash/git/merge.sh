#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 1 'Wrong arguments!'

CIX_SRC_COMMIT="$1"

. $checks/strings/require.sh CIX_SRC_COMMIT

git -C "${CIX_WORKDIR}" merge --no-ff --no-commit "${CIX_SRC_COMMIT}" 2> /dev/null \
 || . $checks/fail.sh 'Git merge error!'
