#!/usr/local/bin/bash

if [[ ! -d "${asserts}" ]]; then
 echo 'No asserts!' >&2; exit 1
elif [[ ! -d "${mocks}" ]]; then
 echo 'No mocks!' >&2; exit 1
fi

TESTS='src/test/bash'

# todo unit_test.sh -> check_tests.sh

. ${TESTS}/gh/check_rates_test.sh
. ${TESTS}/gh/checkout_test.sh
. ${TESTS}/git/merge_test.sh

. ${TESTS}/check_license.sh
. ${TESTS}/check_readme.sh

echo 'All tests passed.'
