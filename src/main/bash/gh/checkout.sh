#!/usr/local/bin/bash

. $checks/strings/require.sh VCS_REP_OWNER VCS_REP_NAME VCS_SOURCE_COMMIT VCS_TARGET_BRANCH GITHUB_PAT

VCS_URL="https://${GITHUB_PAT}@github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git"

git init --quiet \
 || . $checks/fail.sh 'Git init error!'

git remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'

git fetch origin "${VCS_TARGET_BRANCH}" \
 || . $checks/fail.sh "Git fetch \"${VCS_TARGET_BRANCH}\" error!"

git fetch origin "${VCS_SOURCE_COMMIT}" \
 || . $checks/fail.sh "Git fetch \"${VCS_SOURCE_COMMIT}\" error!"

git switch "${VCS_TARGET_BRANCH}" \
 || . $checks/fail.sh "Git switch \"${VCS_TARGET_BRANCH}\" error!"
