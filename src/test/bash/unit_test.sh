#!/usr/local/bin/bash

TESTS='src/test/bash'

# todo unit_test.sh -> check_tests.sh

# todo tests

. ${TESTS}/check_license.sh
. ${TESTS}/check_readme.sh

echo 'All tests were successful.'
