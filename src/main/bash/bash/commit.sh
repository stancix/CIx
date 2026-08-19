#!/usr/local/bin/bash

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME BUILD_VERSION VCS_DST_BRANCH

. $ghx/refs/not_exists.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "tags/${BUILD_VERSION}"

. $cix/git/commit.sh "${BUILD_VERSION}" "${VCS_DST_BRANCH} <- ${BUILD_VERSION}"
