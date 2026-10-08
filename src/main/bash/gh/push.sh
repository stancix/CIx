#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset CIX_WORKER_PAT_SRC

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--worker_pat_src') [[ -v CIX_WORKER_PAT_SRC ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_WORKER_PAT_SRC="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_WORKER_PAT_SRC

[[ ! "${CIX_WORKER_PAT_SRC}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] \
 && . $checks/fail.sh 'Wrong token!'

[[ ! -v "${CIX_WORKER_PAT_SRC}" ]] \
 && . $checks/fail.sh 'Token is unset!'

. $checks/strings/not_empty.sh "${!CIX_WORKER_PAT_SRC}" 'No token!'

git -C "${CIX_WORKDIR}" \
 -c http.extraHeader="$(printf 'Authorization: Basic %s' "$(printf '%s:%s' 'x-access-token' "${!CIX_WORKER_PAT_SRC}" | base64 -w0)")" \
 push --follow-tags \
 || . $checks/fail.sh 'Push error!'

CIX_RESULT_COMMIT="$(git -C "${CIX_WORKDIR}" rev-parse HEAD)" \
 || . $checks/fail.sh 'Get commit SHA error!'

SUBJECT="${CIX_SHARED}/gh_commit.json"

. $ghx/commit.sh "${CIX_REP_OWNER}" "${CIX_REP_NAME}" "${CIX_RESULT_COMMIT}" "${SUBJECT}"
