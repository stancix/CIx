#!/usr/local/bin/bash

unset CIX_REP_OWNER
unset CIX_REP_NAME
unset BUILD_VARIANT

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then
  echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--rep_owner')
   if [[ -v CIX_REP_OWNER ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_REP_OWNER="$2"; shift 2;;
  '--rep_name')
   if [[ -v CIX_REP_NAME ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   CIX_REP_NAME="$2"; shift 2;;
  '--build_variant')
   if [[ -v BUILD_VARIANT ]]; then
    echo "\"$1\" already used!" >&2; exit 1; fi
   BUILD_VARIANT="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

. $checks/strings/require.sh CIX_REP_OWNER CIX_REP_NAME BUILD_VARIANT SIGNING_ALIAS

SCRIPT="${CIX_WORKDIR}/assemble.sh"
. $checks/files/execs.sh "${SCRIPT}"

"${SCRIPT}" "${BUILD_VARIANT}" \
 || . $checks/fail.sh 'Assemble error!'

SUBJECT="${CIX_WORKDIR}/build/yml/metadata.yml"
. $checks/files/not_empty.sh "${SUBJECT}"

#

ACTUAL_VARIANT="$(yq -Mer '.build.variant' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get variant error!'

ACTUAL_REP_OWNER="$(yq -Mer '.repository.owner' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository owner error!'

ACTUAL_REP_NAME="$(yq -Mer '.repository.name' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get repository name error!'

ACTUAL_ALIAS="$(yq -Mer '.signing.alias' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get signing alias error!'

. $checks/strings/eq.sh "${ACTUAL_VARIANT}" "${BUILD_VARIANT}"
. $checks/strings/eq.sh "${ACTUAL_REP_OWNER}" "${CIX_REP_OWNER}"
. $checks/strings/eq.sh "${ACTUAL_REP_NAME}" "${CIX_REP_NAME}"
. $checks/strings/eq.sh "${ACTUAL_ALIAS}" "${SIGNING_ALIAS}"

BUILD_VERSION="$(yq -Mer '.build.version' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get version error!'

SUBJECT="${CIX_WORKDIR}/build/zip/${CIX_REP_NAME}-${BUILD_VERSION}.zip"
. $checks/files/not_empty.sh "${SUBJECT}"
