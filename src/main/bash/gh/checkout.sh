#!/usr/local/bin/bash

. $checks/require.sh REP_OWNER REP_NAME SOURCE_COMMIT TARGET_BRANCH GITHUB_PAT

VCS_URL="https://${GITHUB_PAT}@github.com/${REP_OWNER}/${REP_NAME}.git"

git init \
 || . $checks/fail.sh 'Git init error!'

git remote add origin "${VCS_URL}" \
 || . $checks/fail.sh 'Git remotes error!'

git fetch origin "${TARGET_BRANCH}" \
 || . $checks/fail.sh "Git fetch \"${TARGET_BRANCH}\" error!"

git fetch origin "${SOURCE_COMMIT}" \
 || . $checks/fail.sh "Git fetch \"${SOURCE_COMMIT}\" error!"

git switch "${TARGET_BRANCH}" \
 || . $checks/fail.sh "Git switch \"${TARGET_BRANCH}\" error!"
