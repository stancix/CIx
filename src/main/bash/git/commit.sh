#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 2 'Wrong arguments!'

CIX_COMMIT_TAG="$1"
CIX_COMMIT_MESSAGE="$2"

. $checks/strings/require.sh CIX_COMMIT_TAG CIX_COMMIT_MESSAGE

. $checks/strings/empty.sh "$(git -C "${CIX_WORKDIR}" diff --name-only)" 'Git unstaged error!'

. $checks/strings/empty.sh "$(git -C "${CIX_WORKDIR}" ls-files --others --exclude-standard)" 'Git untracked error!'

git -C "${CIX_WORKDIR}" commit -S -m "${CIX_COMMIT_MESSAGE}" \
 || . $checks/fail.sh 'Git sign commit error!'

git -C "${CIX_WORKDIR}" tag -s "${CIX_COMMIT_TAG}" -m "${CIX_COMMIT_MESSAGE}" \
 || . $checks/fail.sh 'Git sign tag error!'
