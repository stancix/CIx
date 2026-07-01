#!/usr/local/bin/bash

. $checks/strings/require.sh VCS_SOURCE_COMMIT

git -C "${CIX_WORKDIR}" merge --no-ff --no-commit "${VCS_SOURCE_COMMIT}" 2> /dev/null \
 || . $checks/fail.sh 'Git merge error!'
