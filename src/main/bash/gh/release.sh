#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 3 'Wrong arguments!'

CIX_RELEASE_VERSION="$1"
CIX_RELEASE_MESSAGE="$2"
CIX_IS_PRERELEASE="$3"

#. $mt/checks/one_of.sh "${PRERELEASE}" 'false' 'true' # todo

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME CIX_RELEASE_VERSION CIX_RELEASE_MESSAGE

. $ghx/releases/tags/not_exists.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "${CIX_RELEASE_VERSION}"

#

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_ref.json"
. $ghx/ref.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "tags/${CIX_RELEASE_VERSION}" "${SUBJECT}"

CIX_REF_TYPE="$(yq -Mer '.object.type' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get ref type error!'
. $checks/strings/eq.sh "${CIX_REF_TYPE}" 'tag' 'Wrong ref type!'

CIX_REF_SHA="$(yq -Mer '.object.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get ref SHA error!'

#

SUBJECT="${CIX_SHARED}/gh_${CIX_RELEASE_VERSION}_tag.json"
. $ghx/tag.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "${CIX_REF_SHA}" "${SUBJECT}"

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

echo 'Not implemented!'; exit 1 # todo
