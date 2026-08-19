#!/usr/local/bin/bash

echo 'Check rates...'

. $cix/gh/check_rates.sh

echo 'Checkout...'

. $cix/gh/checkout.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}"

echo 'Not implemented!'; exit 1 # todo

echo 'Config...'

. $cix/gh/config.sh

echo 'Merge...'

. $cix/git/merge.sh

echo 'Assemble...'

. $cix/bash/assemble.sh 'unstable'

echo 'Check...'

. $cix/bash/check.sh 'unstable'

echo 'Commit...'

. $cix/bash/commit.sh

echo 'Push...'

. $cix/gh/push.sh

echo 'Release...'

. $cix/bash/gh_release.sh

echo 'Message...'

. $cix/bash/message.sh
