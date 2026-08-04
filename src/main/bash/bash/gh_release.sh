#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

#

SUBJECT="${CIX_SHARED}/gh_commit.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RESULT_COMMIT="$(yq -Mer '.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

#

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_SRC_COMMIT VCS_DST_COMMIT KEYSTORE KEYSTORE_PASSWORD SIGNING_KEY_ALIAS

CIX_PUBLIC_KEY="${CIX_SHARED}/${SIGNING_KEY_ALIAS}_public.pem"
HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "https://${VCS_REP_OWNER}.github.io/${SIGNING_KEY_ALIAS}-public.pem" \
 -o "${CIX_PUBLIC_KEY}" 2>/dev/null) \
 || . $checks/fail.sh 'Request error!'

. $checks/ints/eq.sh "${HTTP_CODE}" 200 'Response error!'

#

SUBJECT="./build/zip/${VCS_REP_NAME}-${ACTUAL_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"

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

. $cix/gh/release.sh "${ACTUAL_VERSION}" "${CIX_RELEASE_MESSAGE}" 'false'

echo 'Not implemented!'; exit 1 # todo

ISSUER_NAME="${REP_NAME}-${VERSION}.zip"
ISSUER="build/zip/${ISSUER_NAME}"

. $mt/gh/release/upload.sh "${VERSION}" "${ISSUER}"        "${ISSUER_NAME}"
