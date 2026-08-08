#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 1 'Wrong arguments!'

BUILD_VARIANT="$1"
. $checks/strings/require.sh BUILD_VARIANT

SCRIPT='./assemble.sh'
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" "${BUILD_VARIANT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

VERSION_NAME="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

SIGNING_TYPE="$(yq -Mer '.signing' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get signing type error!'

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME SIGNING_KEY_ALIAS

. $checks/strings/eq.sh "${ACTUAL_REP_OWNER}" "${VCS_REP_OWNER}"
. $checks/strings/eq.sh "${ACTUAL_REP_NAME}" "${VCS_REP_NAME}"
. $checks/strings/eq.sh "${SIGNING_TYPE}" "${SIGNING_KEY_ALIAS}"

SUBJECT="./build/zip/${VCS_REP_NAME}-${VERSION_NAME}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
