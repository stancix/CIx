#!/usr/local/bin/bash

unset CIX_BUILD_VARIANT

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--build_variant') [[ -v CIX_BUILD_VARIANT ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_BUILD_VARIANT="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_BUILD_VARIANT

SCRIPT="${CIX_WORKDIR}/src/test/bash/checks.sh"
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" --build_variant "${CIX_BUILD_VARIANT}" \
 || . $checks/fail.sh 'Checks error!'
