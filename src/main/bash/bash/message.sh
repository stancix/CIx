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

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME WORKER_BOT_ID WORKER_BOT_SECRET WORKER_CHAT_ID VCS_SRC_COMMIT VCS_DST_COMMIT

CIX_REP_OWNER_URL="https://github.com/${VCS_REP_OWNER}"
CIX_REP_URL="https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}"

SUBJECT="${CIX_SHARED}/gh_${VERSION_NAME}_release.json"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_RELEASE_URL="$(yq -Mer '.html_url' "${SUBJECT}")" \
 || . $checks/fail.sh 'Get release url error!'

#

CIX_CHANGES_URL="${CIX_REP_URL}/compare/${VCS_DST_COMMIT}...${CIX_RESULT_COMMIT}"
CIX_ARTIFACT_URL="${CIX_REP_URL}/releases/download/${VERSION_NAME}/${VCS_REP_NAME}-${VERSION_NAME}.zip"
CIX_MESSAGE="[${VCS_REP_OWNER}](${CIX_REP_OWNER_URL}) / [${VCS_REP_NAME}](${CIX_REP_URL})

\`*\` [${CIX_RESULT_COMMIT::7}](${CIX_REP_URL}/commit/${CIX_RESULT_COMMIT})
\`|\\\`
\`| *\` [${VCS_SRC_COMMIT::7}](${CIX_REP_URL}/commit/${VCS_SRC_COMMIT})
\`*\` [${VCS_DST_COMMIT::7}](${CIX_REP_URL}/commit/${VCS_DST_COMMIT})

\`${VERSION_NAME}\` / [Release](${CIX_RELEASE_URL}) / [Changes](${CIX_CHANGES_URL}) / [Artifact](${CIX_ARTIFACT_URL})"

SUBJECT="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_ASSET_PATH="${SUBJECT}"
CIX_MESSAGE_DST="$(mktemp)"
rm "${CIX_MESSAGE_DST}"
. $tgbots/send_document.sh "${WORKER_BOT_ID}" "${WORKER_BOT_SECRET}" "${WORKER_CHAT_ID}" "${CIX_MESSAGE}" "${CIX_ASSET_PATH}" "${CIX_MESSAGE_DST}"
