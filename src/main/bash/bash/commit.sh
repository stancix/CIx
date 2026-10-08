#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset CIX_DST_BRANCH

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--dst_branch') [[ -v CIX_DST_BRANCH ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_DST_BRANCH="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_DST_BRANCH

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

CIX_BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $ghx/refs/not_exists.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "tags/${CIX_BUILD_VERSION}"

. $cix/git/commit.sh "${CIX_BUILD_VERSION}" "${CIX_DST_BRANCH} <- ${CIX_BUILD_VERSION}"
