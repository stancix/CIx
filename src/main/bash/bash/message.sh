#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 2 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

#

SUBJECT="${CIX_SHARED}/gh_commit.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RESULT_COMMIT="$(yq -Mer '.sha' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get commit SHA error!'

#

. $checks/strings/require.sh WORKER_BOT_ID WORKER_BOT_SECRET WORKER_CHAT_ID VCS_SRC_COMMIT VCS_DST_COMMIT

CIX_REP_OWNER_URL="https://github.com/${CIX_REP_OWNER}"
CIX_REP_URL="https://github.com/${CIX_REP_OWNER}/${CIX_REP_NAME}"

SUBJECT="${CIX_SHARED}/gh_${BUILD_VERSION}_release.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RELEASE_URL="$(yq -Mer '.html_url' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get release url error!'

#

CIX_CHANGES_URL="${CIX_REP_URL}/compare/${VCS_DST_COMMIT}...${CIX_RESULT_COMMIT}"
CIX_SRC_URL="${CIX_REP_URL}/commit/${VCS_SRC_COMMIT}"
CIX_DST_URL="${CIX_REP_URL}/commit/${VCS_DST_COMMIT}"
CIX_RESULT_URL="${CIX_REP_URL}/commit/${CIX_RESULT_COMMIT}"
CIX_ARTIFACT_URL="${CIX_REP_URL}/releases/download/${BUILD_VERSION}/${CIX_REP_NAME}-${BUILD_VERSION}.zip"

CIX_MESSAGE="[${CIX_REP_OWNER}](${CIX_REP_OWNER_URL}) / [${CIX_REP_NAME}](${CIX_REP_URL})

\`*\` [${CIX_RESULT_COMMIT::7}](${CIX_RESULT_URL})
\`|\\\`
\`| *\` [${VCS_SRC_COMMIT::7}](${CIX_SRC_URL})
\`*\` [${VCS_DST_COMMIT::7}](${CIX_DST_URL})

\`${BUILD_VERSION}\` / [Release](${CIX_RELEASE_URL}) / [Changes](${CIX_CHANGES_URL}) / [Artifact](${CIX_ARTIFACT_URL})"

SUBJECT="${CIX_WORKDIR}/build/zip/${CIX_REP_NAME}-${BUILD_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_MESSAGE_DST="$(mktemp)"
rm "${CIX_MESSAGE_DST}"
. $tgbots/send_document.sh "${WORKER_BOT_ID}" WORKER_BOT_SECRET "${WORKER_CHAT_ID}" "${CIX_MESSAGE}" "${SUBJECT}" "${CIX_MESSAGE_DST}"
