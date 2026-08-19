#!/usr/local/bin/bash

. $checks/strings/require.sh GH_WORKER_PAT

#

SUBJECT="${CIX_SHARED}/gh_gpg_keys.json"

. $ghx/user_gpg_keys.sh GH_WORKER_PAT "${SUBJECT}"

CIX_WORKER_KEY_ID="$(yq -Mer '.[0].key_id' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get GPG key ID error!'

#

SUBJECT="${CIX_SHARED}/gh_user.json"

. $ghx/user.sh GH_WORKER_PAT "${SUBJECT}"

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

. $cix/gh/config_keys.sh "${CIX_WORKER_KEY_ID}" "${CIX_USER_EMAIL}"
