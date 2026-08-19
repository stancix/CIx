#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 3 'Wrong arguments!'

CIX_REP_OWNER="$1"
CIX_REP_NAME="$2"
BUILD_VARIANT="$3"

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME BUILD_VARIANT SIGNING_KEY_ALIAS

SCRIPT='./assemble.sh'
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" "${BUILD_VARIANT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_VARIANT="$(yq -Mer '.build.variant' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get variant error!'

. $checks/strings/eq.sh "${ACTUAL_VARIANT}" "${BUILD_VARIANT}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

SIGNING_TYPE="$(yq -Mer '.signing' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get signing type error!'

. $checks/strings/eq.sh "${ACTUAL_REP_OWNER}" "${CIX_REP_OWNER}"
. $checks/strings/eq.sh "${ACTUAL_REP_NAME}" "${CIX_REP_NAME}"
. $checks/strings/eq.sh "${SIGNING_TYPE}" "${SIGNING_KEY_ALIAS}"

SUBJECT="./build/zip/${CIX_REP_NAME}-${BUILD_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
