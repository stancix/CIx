#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 1 'Wrong arguments!'

BUILD_VARIANT="$1"
. $checks/strings/require.sh BUILD_VARIANT

case "${BUILD_VARIANT}" in
 'unstable') SCRIPT='./src/test/bash/check_readme.sh';;
 'release') SCRIPT='./src/test/bash/check_tests.sh';;
 *) echo "Build variant \"${BUILD_VARIANT}\" is not supported!"; exit 1;;
esac

. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" \
 || . $checks/fail.sh 'Check error!'
