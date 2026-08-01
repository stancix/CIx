#!/usr/local/bin/bash

echo 'Check rates...'

. $cix/gh/check_rates.sh

echo 'Checkout...'

. $cix/gh/checkout.sh

echo 'Config...'

. $cix/gh/config.sh

echo 'Merge...'

. $cix/git/merge.sh

echo 'Assemble...'

. $cix/bash/assemble.sh

echo 'Commit...'

. $cix/bash/commit.sh

echo 'Push...'

. $cix/gh/push.sh

echo 'Not implemented!'; exit 1 # todo

# todo push

# todo release

# todo message
