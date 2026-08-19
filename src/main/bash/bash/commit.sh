#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 3 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"
CIX_DST_BRANCH="$3"

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME BUILD_VERSION CIX_DST_BRANCH

. $ghx/refs/not_exists.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "tags/${BUILD_VERSION}"

. $cix/git/commit.sh "${BUILD_VERSION}" "${CIX_DST_BRANCH} <- ${BUILD_VERSION}"
