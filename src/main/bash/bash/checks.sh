#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 1 'Wrong arguments!'

BUILD_VARIANT="$1"

. $checks/strings/require.sh BUILD_VARIANT

SCRIPT="${CIX_WORKDIR}/src/test/bash/checks.sh"
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" "${BUILD_VARIANT}" \
 || . $checks/fail.sh 'Checks error!'
