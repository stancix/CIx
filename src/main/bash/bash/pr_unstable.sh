#!/usr/local/bin/bash

echo 'Check rates...'

. $cix/gh/check_rates.sh

echo 'Init...'

. $cix/gh/init.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}"

echo 'Checkout...'

. $cix/git/checkout.sh "${VCS_SRC_COMMIT}" "${VCS_DST_BRANCH}"

echo 'Config...'

. $cix/gh/config.sh

echo 'Merge...'

. $cix/git/merge.sh "${VCS_SRC_COMMIT}"

echo 'Assemble...'

. $cix/bash/assemble.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" 'unstable'

echo 'Not implemented!'; exit 1 # todo

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
