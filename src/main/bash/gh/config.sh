#!/usr/local/bin/bash

. $checks/strings/require.sh GITHUB_PAT

[[ -f "${GPG_KEY}" ]] \
 || . $checks/fail.sh "File \"${GPG_KEY}\" error!"
#. $checks/files/not_empty.sh "${GPG_KEY}" # todo

gpg --batch --quiet --import "${GPG_KEY}" \
 || . $checks/fail.sh 'GPG import error!'

SUBJECT="${CIX_SHARED}/gh_gpg_keys.json"

$ghx/user_gpg_keys.sh GITHUB_PAT "${SUBJECT}" \
 || . $checks/fail.sh 'Get GPG keys error!'

CIX_USER_KEY_ID="$(yq -Mer '.[0].key_id' "${SUBJECT}")" \
 || . $checks/fail.sh 'GPG key error!'

#

CIX_FILE_KEYS=($(gpg --show-keys --keyid-format long --with-colons "${GPG_KEY}" | grep sec))
. $checks/ints/eq.sh "${#CIX_FILE_KEYS[@]}" 1 'Get file keys error!'

CIX_FILE_KEYS="${CIX_FILE_KEYS[0]}"
CIX_FILE_KEYS=(${CIX_FILE_KEYS//:/ })
CIX_FILE_KEY_ID="${CIX_FILE_KEYS[4]}"
#. $checks/strings/eq.sh "${CIX_USER_KEY_ID}" "${CIX_FILE_KEY_ID}" 'Wrong GPG key!' # todo

#

CIX_ACTUAL_KEYS=($(gpg --list-keys --keyid-format long --with-colons | grep pub))
. $checks/ints/eq.sh "${#CIX_ACTUAL_KEYS[@]}" 1 'Get actual keys error!'

CIX_ACTUAL_KEYS="${CIX_ACTUAL_KEYS[0]}"
CIX_ACTUAL_KEYS=(${CIX_ACTUAL_KEYS//:/ })
CIX_ACTUAL_KEY_ID="${CIX_ACTUAL_KEYS[4]}"
#. $checks/strings/eq.sh "${CIX_USER_KEY_ID}" "${CIX_ACTUAL_KEY_ID}" 'Wrong GPG key!' # todo

#

echo 'Not implemented!'; exit 1 # todo
