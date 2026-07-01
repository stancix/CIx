#!/usr/local/bin/bash

. $checks/strings/require.sh GITHUB_WORKER_PAT

[[ -f "${GPG_KEY}" ]] \
 || . $checks/fail.sh "File \"${GPG_KEY}\" error!"
#. $checks/files/not_empty.sh "${GPG_KEY}" # todo

SUBJECT="${CIX_SHARED}/gh_gpg_keys.json"

. $ghx/user_gpg_keys.sh GITHUB_WORKER_PAT "${SUBJECT}"

CIX_WORKER_KEY_ID="$(yq -Mer '.[0].key_id' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get GPG key ID error!'

#

CIX_FILE_KEYS=($(gpg --show-keys --quiet --keyid-format long --with-colons "${GPG_KEY}" | grep sec)) \
 && $checks/ints/eq.sh "${#CIX_FILE_KEYS[@]}" 1 \
 || . $checks/fail.sh 'Get file keys error!'

CIX_FILE_KEYS="${CIX_FILE_KEYS[0]}"
CIX_FILE_KEYS=(${CIX_FILE_KEYS//:/ })
CIX_FILE_KEY_ID="${CIX_FILE_KEYS[4]}"
#. $checks/strings/eq.sh "${CIX_WORKER_KEY_ID}" "${CIX_FILE_KEY_ID}" 'Wrong GPG key!' # todo

#

gpg --batch --quiet --import "${GPG_KEY}" \
 || . $checks/fail.sh 'GPG import error!'

CIX_ACTUAL_KEYS=($(gpg --list-keys --quiet --keyid-format long --with-colons | grep pub)) \
 && $checks/ints/eq.sh "${#CIX_ACTUAL_KEYS[@]}" 1 \
 || . $checks/fail.sh 'Get file keys error!'

CIX_ACTUAL_KEYS="${CIX_ACTUAL_KEYS[0]}"
CIX_ACTUAL_KEYS=(${CIX_ACTUAL_KEYS//:/ })
CIX_ACTUAL_KEY_ID="${CIX_ACTUAL_KEYS[4]}"
#. $checks/strings/eq.sh "${CIX_WORKER_KEY_ID}" "${CIX_ACTUAL_KEY_ID}" 'Wrong GPG key!' # todo

#

SUBJECT="${CIX_SHARED}/gh_user.json"

$ghx/user.sh GITHUB_WORKER_PAT "${SUBJECT}"

CIX_USER_NAME="$(yq -Mer '.name' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user name error!'

CIX_USER_ID="$(yq -Mer '.id' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user ID error!'

CIX_USER_LOGIN="$(yq -Mer '.login' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user login error!'

CIX_USER_EMAIL="${CIX_USER_ID}+${CIX_USER_LOGIN}@users.noreply.github.com"

# todo
#GPG_UIDS="$(gpg --list-keys --quiet --keyid-format long --with-colons | grep uid)" \
# && $checks/strings/contains.sh "${GPG_UIDS}" "<${CIX_USER_EMAIL}>" \
# || . $checks/fail.sh 'Wrong GPG email!'

CIX_WORKER_KEY_ID='2AC43613F5502EB3C490D2C62CFF9BD0725E548B' # todo
CIX_USER_EMAIL='foo@bar.baz' # todo

#

git config 'user.name' "${CIX_USER_NAME}" \
 || . $checks/fail.sh 'Git config name error!'

git config 'user.email' "${CIX_USER_EMAIL}" \
 || . $checks/fail.sh 'Git config email error!'

git config gpg.program '/usr/local/bin/gpgloopback.sh' \
 || . $checks/fail.sh 'Git config GPG program error!'

git config user.signingkey "${CIX_WORKER_KEY_ID}" \
 || . $checks/fail.sh 'Git config GPG key error!'

