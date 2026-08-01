#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh ACTUAL_REP_OWNER ACTUAL_REP_NAME ACTUAL_VERSION VCS_DST_BRANCH

. $ghx/refs/not_exists.sh "${ACTUAL_REP_OWNER}" "${ACTUAL_REP_NAME}" "tags/${ACTUAL_VERSION}"

. $cix/git/commit.sh "${ACTUAL_VERSION}" "${VCS_DST_BRANCH} <- ${ACTUAL_VERSION}"
