#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

VERSION_NAME="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VERSION_NAME VCS_DST_BRANCH

. $ghx/refs/not_exists.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "tags/${VERSION_NAME}"

. $cix/git/commit.sh "${VERSION_NAME}" "${VCS_DST_BRANCH} <- ${VERSION_NAME}"
