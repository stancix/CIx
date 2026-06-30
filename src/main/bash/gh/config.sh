#!/usr/local/bin/bash

. $checks/strings/require.sh GITHUB_PAT

[[ -f "${GPG_KEY}" ]] \
 || . $checks/fail.sh "File \"${GPG_KEY}\" error!"
#. $checks/files/not_empty.sh "${GPG_KEY}" # todo

gpg --batch --quiet --import "${GPG_KEY}" \
 || . $checks/fail.sh 'GPG import error!'

echo 'Not implemented!'; exit 1 # todo
