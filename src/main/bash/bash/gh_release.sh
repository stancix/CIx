#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset CIX_DST_COMMIT
unset CIX_SIGNING_ALIAS
unset CIX_WORKER_PAT_SRC
unset CIX_SIGNING_PASSWORD_SRC

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--dst_commit') [[ -v CIX_DST_COMMIT ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_DST_COMMIT="$2"; shift 2;;
  '--signing_alias') [[ -v CIX_SIGNING_ALIAS ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_SIGNING_ALIAS="$2"; shift 2;;
  '--worker_pat_src') [[ -v CIX_WORKER_PAT_SRC ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_WORKER_PAT_SRC="$2"; shift 2;;
  '--signing_password_src') [[ -v CIX_SIGNING_PASSWORD_SRC ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_SIGNING_PASSWORD_SRC="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_DST_COMMIT CIX_SIGNING_ALIAS

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

#

SUBJECT="${CIX_SHARED}/gh_commit.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RESULT_COMMIT="$(yq -Mer '.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

#

echo 'Get public key...'

CIX_PUBLIC_KEY="${CIX_SHARED}/${CIX_SIGNING_ALIAS}_public.pem"
. $ghx/pages/file.sh "${CIX_REP_OWNER}" "${CIX_SIGNING_ALIAS}-public.pem" "${CIX_PUBLIC_KEY}"

CIX_KEYSTORE="${CIX_SHARED}/${CIX_SIGNING_ALIAS}.pkcs12"
CIX_PRIVATE_KEY="${CIX_SHARED}/${CIX_SIGNING_ALIAS}.key"
. $secrets/pkcs12/key.sh "${CIX_KEYSTORE}" "${CIX_PRIVATE_KEY}" "${CIX_SIGNING_PASSWORD_SRC}"

CIX_CRT="${CIX_SHARED}/${CIX_SIGNING_ALIAS}.crt"
. $secrets/pkcs12/crt.sh "${CIX_KEYSTORE}" "${CIX_CRT}" "${CIX_SIGNING_PASSWORD_SRC}"
. $secrets/x509/valid.sh "${CIX_CRT}"

SUBJECT="${CIX_WORKDIR}/build/zip/${CIX_REP_NAME}-${CIX_BUILD_VERSION}.zip"
. $secrets/signing/sign.sh "${SUBJECT}" "${SUBJECT}.sig" "${CIX_PRIVATE_KEY}" 'sha256' "${CIX_SIGNING_PASSWORD_SRC}"
. $secrets/signing/verify.sh "${SUBJECT}" "${SUBJECT}.sig" "${CIX_PUBLIC_KEY}" 'sha256'
. $hashes/sha256.sh "${SUBJECT}" "${SUBJECT}.sha256"

#

openssl ts -query -data "${SUBJECT}.sig" -sha256 -cert -out "${SUBJECT}.sig.tsq" \
 || . $checks/fail.sh "Get \"${SUBJECT}.sig.tsq\" error!"

HTTP_CODE="$(curl -m 8 -w '%{http_code}' \
 --url 'https://freetsa.org/tsr' \
 --header 'Content-Type: application/timestamp-query' \
 --data-binary "@${SUBJECT}.sig.tsq" \
 --output "${SUBJECT}.sig.tsr")" \
 && $checks/ints/eq.sh "${HTTP_CODE}" '200' \
 || . $checks/fail.sh "Get \"${SUBJECT}.sig.tsr\" error!"

#

CIX_REP_URL="https://github.com/${CIX_REP_OWNER}/${CIX_REP_NAME}"

CIX_CHANGES_URL="${CIX_REP_URL}/compare/${CIX_DST_COMMIT}...${CIX_RESULT_COMMIT}"
CIX_DST_URL="${CIX_REP_URL}/commit/${CIX_DST_COMMIT}"
CIX_RESULT_URL="${CIX_REP_URL}/commit/${CIX_RESULT_COMMIT}"

CIX_RELEASE_MESSAGE="
[Changes](${CIX_CHANGES_URL}) from [${CIX_DST_COMMIT::7}](${CIX_DST_URL}) to [${CIX_RESULT_COMMIT::7}](${CIX_RESULT_URL})

sha256: \`$(xxd -ps -c 32 -l 32 "${SUBJECT}.sha256")\`
"

if [[ "${CIX_SIGNING_ALIAS}" == 'release' ]]; then
 CIX_IS_PRERELEASE='false'
else
 CIX_IS_PRERELEASE='true'
fi

. $cix/gh/release.sh --rep_owner "${CIX_REP_OWNER}" --rep_name "${CIX_REP_NAME}" --version "${CIX_BUILD_VERSION}" --message "${CIX_RELEASE_MESSAGE}" --is_prerelease "${CIX_IS_PRERELEASE}" --worker_pat_src "${CIX_WORKER_PAT_SRC}"

SUBJECT="${CIX_SHARED}/gh_${CIX_BUILD_VERSION}_release.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RELEASE_ID="$(yq -Mer '.id' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get release ID error!'

CIX_ASSET_PATH="${CIX_WORKDIR}/build/zip/${CIX_REP_NAME}-${CIX_BUILD_VERSION}.zip"
CIX_ASSET_NAME="${CIX_REP_NAME}-${CIX_BUILD_VERSION}.zip"
CIX_UPLOAD_DST="$(mktemp)"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_WORKER_PAT_SRC}" "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}" "${CIX_ASSET_NAME}" "${CIX_UPLOAD_DST}"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_WORKER_PAT_SRC}" "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}.sig" "${CIX_ASSET_NAME}.sig" "${CIX_UPLOAD_DST}"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_WORKER_PAT_SRC}" "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}.sha256" "${CIX_ASSET_NAME}.sha256" "${CIX_UPLOAD_DST}"

rm "${CIX_UPLOAD_DST}"
. $ghx/releases/upload.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_WORKER_PAT_SRC}" "${CIX_RELEASE_ID}" \
 "${CIX_ASSET_PATH}.sig.tsr" "${CIX_ASSET_NAME}.sig.tsr" "${CIX_UPLOAD_DST}"
