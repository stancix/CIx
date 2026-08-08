#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

VERSION_NAME="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

#

SUBJECT="${CIX_SHARED}/gh_commit.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RESULT_COMMIT="$(yq -Mer '.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

#

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_DST_COMMIT SIGNING_KEY_ALIAS GITHUB_WORKER_PAT

CIX_PUBLIC_KEY="${CIX_SHARED}/${SIGNING_KEY_ALIAS}_public.pem"
HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "https://${VCS_REP_OWNER}.github.io/${SIGNING_KEY_ALIAS}-public.pem" \
 -o "${CIX_PUBLIC_KEY}" 2>/dev/null) \
 || . $checks/fail.sh 'Request error!'

. $checks/ints/eq.sh "${HTTP_CODE}" 200 'Get public key error!'

#

echo 'Not implemented! Get public key'; exit 1 # todo

SUBJECT="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"

#. $checks/strings/require.sh KEYSTORE KEYSTORE_PASSWORD

#. $mt/secrets/sign.sh              "${ISSUER}" "${KEYSTORE}" "${KEYSTORE_PASSWORD}" # todo
#. $mt/secrets/sign/check.sh        "${ISSUER}" "${KEYSTORE}" "${KEYSTORE_PASSWORD}" # todo
#. $mt/secrets/sign/check/public.sh "${ISSUER}" "${PUBLIC_KEY}" # todo
#. $mt/hashes/sha256.sh             "${ISSUER}" # todo

CIX_REP_URL="https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}"

CIX_CHANGES_URL="${CIX_REP_URL}/compare/${VCS_DST_COMMIT}...${CIX_RESULT_COMMIT}"
CIX_DST_URL="${CIX_REP_URL}/commit/${VCS_DST_COMMIT}"
CIX_RESULT_URL="${CIX_REP_URL}/commit/${CIX_RESULT_COMMIT}"

CIX_RELEASE_MESSAGE="
[Changes](${CIX_CHANGES_URL}) from [${VCS_DST_COMMIT::7}](${CIX_DST_URL}) to [${CIX_RESULT_COMMIT::7}](${CIX_RESULT_URL})
"

if [[ "${SIGNING_KEY_ALIAS}" == 'release' ]]; then
 CIX_IS_PRERELEASE='false'
else
 CIX_IS_PRERELEASE='true'
fi

. $cix/gh/release.sh "${ACTUAL_VVERSION_NAMEERSION}" "${CIX_RELEASE_MESSAGE}" "${CIX_IS_PRERELEASE}"

SUBJECT="${CIX_SHARED}/gh_${VERSION_NAME}_release.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RELEASE_ID="$(yq -Mer '.id' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get release ID error!'

CIX_ASSET_PATH="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
CIX_ASSET_NAME="${VCS_REP_NAME}-${VERSION_NAME}.zip"
SUBJECT="$(mktemp)"; rm "${SUBJECT}"
. $ghx/releases/upload.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" GITHUB_WORKER_PAT "${CIX_RELEASE_ID}" "${CIX_ASSET_PATH}" "${CIX_ASSET_NAME}" "${SUBJECT}"
