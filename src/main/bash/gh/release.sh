#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 5 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"
CIX_RELEASE_VERSION="$3"
CIX_RELEASE_MESSAGE="$4"
CIX_IS_PRERELEASE="$5"

#. $mt/checks/one_of.sh "${PRERELEASE}" 'false' 'true' # todo

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_RELEASE_VERSION CIX_RELEASE_MESSAGE GH_WORKER_PAT

echo "Check release \"${CIX_RELEASE_VERSION}\"..."

. $ghx/releases/tags/not_exists.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_RELEASE_VERSION}"

#

echo "Get ref \"${CIX_RELEASE_VERSION}\"..."

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_ref.json"
#. $ghx/ref.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "tags/${CIX_RELEASE_VERSION}" "${SUBJECT}" # todo

GITHUBX_API='https://api.github.com'
GITHUBX_API_VERSION='2026-03-10'
HTTP_CODE=$(curl -m 8 -w '%{http_code}' \
 "${GITHUBX_API}/repos/${CIX_REP_OWNER}/${CIX_REP_NAME}/git/ref/tags/${CIX_RELEASE_VERSION}" \
 --url-query "salt=${RANDOM}" \
 --header 'Accept: application/vnd.github+json' \
 --header "X-GitHub-Api-Version: ${GITHUBX_API_VERSION}" \
 -o "${SUBJECT}" 2>/dev/null)

if [[ $? -ne 0 ]]; then
 echo 'Request error!' >&2; exit 1
elif [[ "${HTTP_CODE}" != '200' ]]; then
 echo 'Response error!' >&2; exit 1
fi

CIX_REF_TYPE="$(yq -Mer '.object.type' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get ref type error!'
. $checks/strings/eq.sh "${CIX_REF_TYPE}" 'tag' 'Wrong ref type!'

CIX_REF_SHA="$(yq -Mer '.object.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get ref SHA error!'

#

echo "Get tag \"${CIX_RELEASE_VERSION}\"..."

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_tag.json"
. $ghx/tag.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_REF_SHA}" "${SUBJECT}"

CIX_TAG_VERIFIED="$(yq -Me '.verification.verified' "${SUBJECT}" 2> /dev/null)" \
 && $checks/strings/eq.sh "${CIX_TAG_VERIFIED}" 'true' \
 || . $checks/fail.sh 'Tag verification error!'

CIX_COMMIT_SHA="$(yq -Mer '.object.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

SUBJECT="${CIX_SHARED}/gh_commit.json"
CIX_RESULT_COMMIT="$(yq -Mer '.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

. $checks/strings/eq.sh "${CIX_COMMIT_SHA}" "${CIX_RESULT_COMMIT}" 'Wrong commit SHA!'

#

echo "Release \"${CIX_RELEASE_VERSION}\"..."

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_release.json"
. $ghx/release.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" GH_WORKER_PAT "${CIX_RESULT_COMMIT}" "${CIX_RELEASE_VERSION}" "${CIX_RELEASE_MESSAGE}" "${CIX_IS_PRERELEASE}" "${SUBJECT}"
