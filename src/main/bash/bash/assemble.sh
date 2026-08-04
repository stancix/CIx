#!/usr/local/bin/bash

SCRIPT='./assemble.sh'
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME

. $checks/strings/eq.sh "${ACTUAL_REP_OWNER}" "${VCS_REP_OWNER}"
. $checks/strings/eq.sh "${ACTUAL_REP_NAME}" "${VCS_REP_NAME}"

SUBJECT="./build/zip/${VCS_REP_NAME}-${ACTUAL_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
