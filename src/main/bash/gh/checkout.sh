#!/usr/local/bin/bash

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_SOURCE_COMMIT VCS_TARGET_BRANCH GITHUB_WORKER_PAT

VCS_URL="https://${GITHUB_WORKER_PAT}@github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $checks/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'

git -C "${CIX_WORKDIR}" fetch origin "${VCS_TARGET_BRANCH}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_TARGET_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${VCS_SOURCE_COMMIT}" --quiet \
 || . $checks/fail.sh "Git fetch \"${VCS_SOURCE_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${VCS_TARGET_BRANCH}" --quiet \
 || . $checks/fail.sh "Git switch \"${VCS_TARGET_BRANCH}\" error!"
