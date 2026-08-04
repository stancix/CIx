#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME ACTUAL_VERSION VCS_DST_BRANCH

. $ghx/refs/not_exists.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "tags/${ACTUAL_VERSION}"

. $cix/git/commit.sh "${ACTUAL_VERSION}" "${VCS_DST_BRANCH} <- ${ACTUAL_VERSION}"
