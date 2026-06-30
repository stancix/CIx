#!/usr/local/bin/bash

SCRIPT='./src/test/bash/check_tests.sh'
#. $checks/files/execs.sh "${SCRIPT}" # todo

"${SCRIPT}" \
 || . $checks/fail.sh 'Check error!'
