#!/usr/local/bin/bash

. $checks/ints/eq.sh $# 2 'Wrong arguments!'

CIX_COMMIT_TAG="$1"
CIX_COMMIT_MESSAGE="$2"

. $checks/strings/require.sh CIX_COMMIT_TAG CIX_COMMIT_MESSAGE

git add . \
 || . $checks/fail.sh 'Git add error!'

git commit -S -m "${CIX_COMMIT_MESSAGE}" \
 || . $checks/fail.sh 'Git sign commit error!'

git tag -s "${CIX_COMMIT_TAG}" -m "${CIX_COMMIT_MESSAGE}" \
 || . $checks/fail.sh 'Git sign tag error!'
