#!/usr/local/bin/bash

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_SRC_COMMIT VCS_DST_BRANCH GITHUB_WORKER_PAT

VCS_URL="https://${GITHUB_WORKER_PAT}@github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $checks/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'

git -C "${CIX_WORKDIR}" fetch origin "${VCS_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${VCS_SRC_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${VCS_DST_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${VCS_DST_BRANCH}\" error!"
