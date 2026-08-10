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

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_DST_COMMIT SIGNING_KEY_ALIAS GITHUB_WORKER_PAT KEYS_PASSWORD

CIX_PUBLIC_KEY="${CIX_SHARED}/${SIGNING_KEY_ALIAS}_public.pem"
HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "https://${VCS_REP_OWNER}.github.io/${SIGNING_KEY_ALIAS}-public.pem" \
 -o "${CIX_PUBLIC_KEY}" 2>/dev/null) \
 || . $checks/fail.sh 'Request error!'

. $checks/ints/eq.sh "${HTTP_CODE}" 200 'Get public key error!'

#

SUBJECT="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
CIX_KEYSTORE="${CIX_SHARED}/${SIGNING_KEY_ALIAS}.pkcs12"
CIX_PRIVATE_KEY="${CIX_SHARED}/${SIGNING_KEY_ALIAS}.key"
openssl pkcs12 -in "${CIX_KEYSTORE}" -nocerts -passin 'env:KEYS_PASSWORD' -passout 'env:KEYS_PASSWORD' -out "${CIX_PRIVATE_KEY}" \
 || . $checks/fail.sh 'Get private key error!'

CIX_CRT="${CIX_SHARED}/${SIGNING_KEY_ALIAS}.crt"
openssl pkcs12 -in "${CIX_KEYSTORE}" -nokeys -passin 'env:KEYS_PASSWORD' -out "${CIX_CRT}" \
 || . $checks/fail.sh 'Get crt error!'

openssl x509 -in "${CIX_CRT}" -checkend 0 > /dev/null \
 || . $checks/fail.sh 'Check crt error!'

. $secrets/signing/sign.sh "${SUBJECT}" "${SUBJECT}.sig" "${CIX_PRIVATE_KEY}" 'sha256' KEYS_PASSWORD
. $secrets/signing/verify.sh "${SUBJECT}" "${SUBJECT}.sig" "${CIX_PUBLIC_KEY}" 'sha256'
. $hashes/sha256.sh "${SUBJECT}" "${SUBJECT}.sha256"

CIX_REP_URL="https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}"

CIX_CHANGES_URL="${CIX_REP_URL}/compare/${VCS_DST_COMMIT}...${CIX_RESULT_COMMIT}"
CIX_DST_URL="${CIX_REP_URL}/commit/${VCS_DST_COMMIT}"
CIX_RESULT_URL="${CIX_REP_URL}/commit/${CIX_RESULT_COMMIT}"

CIX_RELEASE_MESSAGE="
[Changes](${CIX_CHANGES_URL}) from [${VCS_DST_COMMIT::7}](${CIX_DST_URL}) to [${CIX_RESULT_COMMIT::7}](${CIX_RESULT_URL})

sha256: \`$(xxd -ps -c 32 -l 32 "${SUBJECT}.sha256")\`
"

if [[ "${SIGNING_KEY_ALIAS}" == 'release' ]]; then
 CIX_IS_PRERELEASE='false'
else
 CIX_IS_PRERELEASE='true'
fi

. $cix/gh/release.sh "${VERSION_NAME}" "${CIX_RELEASE_MESSAGE}" "${CIX_IS_PRERELEASE}"

SUBJECT="${CIX_SHARED}/gh_${VERSION_NAME}_release.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RELEASE_ID="$(yq -Mer '.id' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get release ID error!'

CIX_ASSET_PATH="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
CIX_ASSET_NAME="${VCS_REP_NAME}-${VERSION_NAME}.zip"
CIX_UPLOAD_DST="$(mktemp)"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" GITHUB_WORKER_PAT "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}" "${CIX_ASSET_NAME}" "${CIX_UPLOAD_DST}"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" GITHUB_WORKER_PAT "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}.sig" "${CIX_ASSET_NAME}.sig" "${CIX_UPLOAD_DST}"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" GITHUB_WORKER_PAT "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}.sha256" "${CIX_ASSET_NAME}.sha256" "${CIX_UPLOAD_DST}"
