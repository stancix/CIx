#!/usr/local/bin/bash

unset BUILD_VARIANT

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then
  echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--build_variant')
   if [[ -v BUILD_VARIANT ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   BUILD_VARIANT="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh BUILD_VARIANT

SCRIPT="${CIX_WORKDIR}/src/test/bash/checks.sh"
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" "${BUILD_VARIANT}" \
 || . $checks/fail.sh 'Checks error!'
