#!/usr/local/bin/bash

echo 'Check rates...'

. $cix/gh/check_rates.sh

echo 'Init...'

. $cix/gh/init.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}"

echo 'Checkout...'

. $cix/git/checkout.sh --src_commit "${VCS_SRC_COMMIT}" --dst_branch "${VCS_DST_BRANCH}"

echo 'Config...'

. $cix/gh/config.sh --worker_pat_src GH_WORKER_PAT

echo 'Merge...'

. $cix/git/merge.sh --src_commit "${VCS_SRC_COMMIT}"

echo 'Assemble...'

. $cix/bash/assemble.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --build_variant 'unstable' --signing_alias "${SIGNING_ALIAS}"

echo 'Checks...'

. $cix/bash/checks.sh --build_variant 'unstable'

echo 'Commit...'

. $cix/bash/commit.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --dst_branch "${VCS_DST_BRANCH}"

echo 'Push...'

. $cix/gh/push.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --worker_pat_src GH_WORKER_PAT

echo 'Release...'

. $cix/bash/gh_release.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --dst_commit "${VCS_DST_COMMIT}" --signing_alias "${SIGNING_ALIAS}" --worker_pat_src GH_WORKER_PAT --signing_password_src SIGNING_PASSWORD

echo 'Message...'

. $cix/bash/message.sh --rep_owner "${VCS_REP_OWNER}" --rep_name "${VCS_REP_NAME}" --src_commit "${VCS_SRC_COMMIT}" --dst_commit "${VCS_DST_COMMIT}" --bot_id "${WORKER_BOT_ID}" --bot_secret_src WORKER_BOT_SECRET --chat_id "${WORKER_CHAT_ID}"
