#!/usr/local/bin/bash

$cix/gh/check_rates.sh \
 || . $checks/fail.sh 'GitHub check rates error!'

$cix/gh/checkout.sh \
 || . $checks/fail.sh 'GitHub checkout error!'

$cix/gh/config.sh \
 || . $checks/fail.sh 'GitHub config error!'

. $cix/git/merge.sh

echo 'Not implemented!'; exit 1 # todo

# todo checks

# todo release
