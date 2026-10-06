#!/usr/local/bin/bash

echo 'Check rates...'

. $cix/gh/check_rates.sh

echo 'Init...'

. $cix/gh/init.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}"

echo 'Checkout...'

. $cix/git/checkout.sh --src_commit "${VCS_SRC_COMMIT}" --dst_branch "${VCS_DST_BRANCH}"

echo 'Config...'

. $cix/gh/config.sh

echo 'Merge...'

. $cix/git/merge.sh "${VCS_SRC_COMMIT}"

echo 'Assemble...'

. $cix/bash/assemble.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --build_variant 'unstable'

echo 'Checks...'

. $cix/bash/checks.sh --build_variant 'unstable'

echo 'Commit...'

. $cix/bash/commit.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --dst_branch "${VCS_DST_BRANCH}"

echo 'Push...'

. $cix/gh/push.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}"

echo 'Release...'

. $cix/bash/gh_release.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "${VCS_DST_COMMIT}"

echo 'Message...'

. $cix/bash/message.sh "${VCS_REP_OWNER}" "${VCS_REP_NAME}" "${VCS_SRC_COMMIT}" "${VCS_DST_COMMIT}"
