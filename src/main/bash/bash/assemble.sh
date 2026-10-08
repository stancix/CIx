#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset CIX_BUILD_VARIANT
unset CIX_SIGNING_ALIAS

while [[ $# -gt 0 ]]; do
 . $checks/ints/gt.sh $# 1 'Wrong flags!'
 case "$1" in
  '--rep_owner') [[ -v CIX_REP_OWNER ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name') [[ -v CIX_REP_NAME ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_REP_NAME="$2"; shift 2;;
  '--build_variant') [[ -v CIX_BUILD_VARIANT ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_BUILD_VARIANT="$2"; shift 2;;
  '--signing_alias') [[ -v CIX_SIGNING_ALIAS ]] && . $checks/fail.sh "\"$1\" already used!"
   CIX_SIGNING_ALIAS="$2"; shift 2;;
  *) . $checks/fail.sh "\"$1\" is not supported!";;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME CIX_BUILD_VARIANT CIX_SIGNING_ALIAS

SCRIPT="${CIX_WORKDIR}/assemble.sh"
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" --build_variant "${CIX_BUILD_VARIANT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

#

ACTUAL_BUILD_VARIANT="$(yq -Mer '.build.variant' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get variant error!'

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

ACTUAL_ALIAS="$(yq -Mer '.signing.alias' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get signing alias error!'

. $checks/strings/eq.sh "${ACTUAL_BUILD_VARIANT}" "${CIX_BUILD_VARIANT}"
. $checks/strings/eq.sh "${ACTUAL_REP_OWNER}" "${CIX_REP_OWNER}"
. $checks/strings/eq.sh "${ACTUAL_REP_NAME}" "${CIX_REP_NAME}"
. $checks/strings/eq.sh "${ACTUAL_ALIAS}" "${CIX_SIGNING_ALIAS}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

SUBJECT="${CIX_WORKDIR}/build/zip/${CIX_REP_NAME}-${BUILD_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
