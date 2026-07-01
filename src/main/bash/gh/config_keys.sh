#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 3 'Wrong arguments!'

CIX_WORKER_KEY_ID="$1"
CIX_WORKER_KEY="$2"
CIX_WORKER_EMAIL="$3"

. $checks/strings/require.sh CIX_WORKER_KEY_ID CIX_WORKER_KEY CIX_WORKER_EMAIL

[[ -f "${CIX_WORKER_KEY}" ]] \
 || . $checks/fail.sh "File \"${CIX_WORKER_KEY}\" error!"
#. $checks/files/not_empty.sh "${CIX_WORKER_KEY}" # todo

CIX_FILE_KEYS=($(gpg --show-keys --quiet --keyid-format long --with-colons "${CIX_WORKER_KEY}" | grep sec)) \
 && $checks/ints/eq.sh "${#CIX_FILE_KEYS[@]}" 1 \
 || . $checks/fail.sh 'Get file keys error!'

CIX_FILE_KEYS="${CIX_FILE_KEYS[0]}"
CIX_FILE_KEYS=(${CIX_FILE_KEYS//:/ })
CIX_FILE_KEY_ID="${CIX_FILE_KEYS[4]}"
. $checks/strings/eq.sh "${CIX_WORKER_KEY_ID}" "${CIX_FILE_KEY_ID}" 'Wrong GPG key!'

#

gpg --batch --quiet --import "${CIX_WORKER_KEY}" \
 || . $checks/fail.sh 'GPG import error!'

CIX_ACTUAL_KEYS=($(gpg --list-keys --quiet --keyid-format long --with-colons | grep pub)) \
 && $checks/ints/eq.sh "${#CIX_ACTUAL_KEYS[@]}" 1 \
 || . $checks/fail.sh 'Get file keys error!'

CIX_ACTUAL_KEYS="${CIX_ACTUAL_KEYS[0]}"
CIX_ACTUAL_KEYS=(${CIX_ACTUAL_KEYS//:/ })
CIX_ACTUAL_KEY_ID="${CIX_ACTUAL_KEYS[4]}"
. $checks/strings/eq.sh "${CIX_WORKER_KEY_ID}" "${CIX_ACTUAL_KEY_ID}" 'Wrong GPG key!'

#

# todo $checks/strings/contains.sh
CIX_GPG_UIDS="$(gpg --list-keys --quiet --keyid-format long --with-colons | grep uid)" \
 && [[ "${CIX_GPG_UIDS}" == *"<${CIX_WORKER_EMAIL}>"* ]] \
 || . $checks/fail.sh 'Wrong GPG email!'

#

git -C "${CIX_WORKDIR}" config gpg.program '/usr/local/bin/gpgloopback.sh' \
 || . $checks/fail.sh 'Git config GPG program error!'

git -C "${CIX_WORKDIR}" config user.signingkey "${CIX_WORKER_KEY_ID}" \
 || . $checks/fail.sh 'Git config GPG key error!'
