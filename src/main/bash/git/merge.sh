#!/usr/local/bin/bash

. $checks/strings/require.sh VCS_SOURCE_COMMIT

git merge --no-ff --no-commit "${VCS_SOURCE_COMMIT}" \
 || . $checks/fail.sh 'Git merge error!'
