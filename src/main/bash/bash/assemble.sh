#!/usr/local/bin/bash

SCRIPT='./assemble.sh'
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT='./build/yml/metadata.yml'
. $checks/files/not_empty.sh "${SUBJECT}"

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

SUBJECT="./build/zip/${ACTUAL_REP_NAME}-${ACTUAL_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
