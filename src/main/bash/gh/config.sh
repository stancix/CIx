#!/usr/local/bin/bash

unset CIX_WORKER_PAT_SRC

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--worker_pat_src') [[ -v CIX_WORKER_PAT_SRC ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_WORKER_PAT_SRC="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

#

SUBJECT="${CIX_SHARED}/gh_gpg_keys.json"

. $ghx/user_gpg_keys.sh CIX_WORKER_PAT_SRC "${SUBJECT}"

CIX_WORKER_KEY_ID="$(yq -Mer '.[0].key_id' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get GPG key ID error!'

#

SUBJECT="${CIX_SHARED}/gh_user.json"

. $ghx/user.sh CIX_WORKER_PAT_SRC "${SUBJECT}"

CIX_USER_NAME="$(yq -Mer '.name' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user name error!'

CIX_USER_ID="$(yq -Mer '.id' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user ID error!'

CIX_USER_LOGIN="$(yq -Mer '.login' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get user login error!'

CIX_USER_EMAIL="${CIX_USER_ID}+${CIX_USER_LOGIN}@users.noreply.github.com"

#

git -C "${CIX_WORKDIR}" config 'user.name' "${CIX_USER_NAME}" \
 || . $checks/fail.sh 'Git config name error!'

git -C "${CIX_WORKDIR}" config 'user.email' "${CIX_USER_EMAIL}" \
 || . $checks/fail.sh 'Git config email error!'

echo 'Config keys...'

. $cix/gh/config_keys.sh --worker_key_id "${CIX_WORKER_KEY_ID}" --worker_email "${CIX_USER_EMAIL}"
