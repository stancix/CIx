#!/usr/local/bin/bash

SUBJECT='./build/yml/metadata.yml'
#. $checks/files/not_empty.sh "${SUBJECT}" # todo

ACTUAL_VERSION="$(yq -Mer '.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $checks/strings/require.sh ACTUAL_VERSION VCS_TARGET_BRANCH

echo 'Not implemented!'; exit 1 # todo

#. $mt/gh/tag/test.sh "${VERSION}" # todo

. $cix/git/commit.sh "${ACTUAL_VERSION}" "${VCS_TARGET_BRANCH} <- ${ACTUAL_VERSION}"
