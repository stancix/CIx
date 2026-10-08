#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset CIX_RELEASE_VERSION
unset CIX_RELEASE_MESSAGE
unset CIX_IS_PRERELEASE
unset CIX_WORKER_PAT_SRC

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--version') [[ -v CIX_RELEASE_VERSION ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_RELEASE_VERSION="$2"; shift 2;;
  '--message') [[ -v CIX_RELEASE_MESSAGE ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_RELEASE_MESSAGE="$2"; shift 2;;
  '--is_prerelease') [[ -v CIX_IS_PRERELEASE ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_IS_PRERELEASE="$2"; shift 2;;
  '--worker_pat_src') [[ -v CIX_WORKER_PAT_SRC ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_WORKER_PAT_SRC="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/any.sh "${CIX_IS_PRERELEASE}" 'false' 'true' 'Wrong prerelease!'

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_RELEASE_VERSION CIX_RELEASE_MESSAGE

echo "Check release \"${CIX_RELEASE_VERSION}\"..."

. $ghx/releases/tags/not_exists.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_RELEASE_VERSION}"

#

echo "Get ref \"${CIX_RELEASE_VERSION}\"..."

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_ref.json"
. $ghx/ref.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "tags/${CIX_RELEASE_VERSION}" "${SUBJECT}" "${RANDOM}"

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
. $ghx/release.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" CIX_WORKER_PAT_SRC "${CIX_RESULT_COMMIT}" "${CIX_RELEASE_VERSION}" "${CIX_RELEASE_MESSAGE}" "${CIX_IS_PRERELEASE}" "${SUBJECT}"
