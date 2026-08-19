#!/usr/local/bin/bash

if [[ $# -ne 1 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

BUILD_VARIANT="$1"
if [[ ! -d "${asserts}" ]]; then
 echo 'No asserts!' >&2; exit 1
elif [[ ! -d "${mocks}" ]]; then
 echo 'No mocks!' >&2; exit 1
fi

TESTS='src/test/bash'

case "${BUILD_VARIANT}" in
 'unstable');;
 'release')
  . ${TESTS}/gh/check_rates_test.sh
  . ${TESTS}/gh/init_test.sh
  . ${TESTS}/gh/config_keys_test.sh
  . ${TESTS}/git/merge_test.sh
  . ${TESTS}/check_license.sh
 ;;
 '') echo 'No build variant!' >&2; exit 1;;
 *) echo "Build variant \"${BUILD_VARIANT}\" is not supported!" >&2; exit 1;;
esac

. ${TESTS}/check_readme.sh

echo 'All tests passed.'
