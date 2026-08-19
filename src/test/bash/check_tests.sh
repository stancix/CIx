#!/usr/local/bin/bash

TESTS='src/test/bash'

. ${TESTS}/bash/assemble_test.sh
. ${TESTS}/bash/checks_test.sh
. ${TESTS}/gh/check_rates_test.sh
. ${TESTS}/gh/config_keys_test.sh
. ${TESTS}/gh/init_test.sh
. ${TESTS}/git/merge_test.sh
