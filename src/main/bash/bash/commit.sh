#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset BUILD_VARIANT

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/files/execs.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/files/execs.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--dst_branch') [[ -v CIX_DST_BRANCH ]] && . $checks/files/execs.sh "\"$1\" already used!"
   CIX_DST_BRANCH="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_DST_BRANCH

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

. $ghx/refs/not_exists.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "tags/${BUILD_VERSION}"

. $cix/git/commit.sh "${BUILD_VERSION}" "${CIX_DST_BRANCH} <- ${BUILD_VERSION}"
