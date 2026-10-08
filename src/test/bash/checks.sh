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

if [[ ! -d "${asserts}" ]]; then
 echo 'No asserts!' >&2; exit 1
elif [[ ! -d "${mocks}" ]]; then
 echo 'No mocks!' >&2; exit 1
fi

TESTS='src/test/bash'

case "${BUILD_VARIANT}" in
 'unstable')
  . ${TESTS}/check_license.sh
  . ${TESTS}/check_readme.sh
 ;;
 'release')
  . ${TESTS}/check_tests.sh
  . ${TESTS}/check_license.sh
  . ${TESTS}/check_readme.sh
 ;;
 '') echo 'No build variant!' >&2; exit 1;;
 *) echo "Build variant \"${BUILD_VARIANT}\" is not supported!" >&2; exit 1;;
esac

echo 'All tests passed.'
