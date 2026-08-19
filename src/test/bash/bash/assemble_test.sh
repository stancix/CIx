#!/usr/local/bin/bash

SCRIPT='src/main/bash/bash/assemble.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

TEST_REP_OWNER='testrepowner'
TEST_REP_NAME='testrepname'
TEST_VARIANT='testvariant'
TEST_VERSION='testversion'
TEST_ALIAS='testalias'

CIX_WORKDIR="$(mktemp -d)"

printf '%s' "\
[[ '${TEST_VARIANT}' == \"\$1\" ]] || exit 1
mkdir '${CIX_WORKDIR}/build/'
mkdir '${CIX_WORKDIR}/build/yml/'
printf '%s' '{
 \"repository\":{\"owner\":\"${TEST_REP_OWNER}\",\"name\":\"${TEST_REP_NAME}\"},
 \"build\":{\"variant\":\"${TEST_VARIANT}\",\"version\":\"${TEST_VERSION}\"},
 \"signing\":{\"alias\":\"${TEST_ALIAS}\"}
}' > '${CIX_WORKDIR}/build/yml/metadata.yml'
mkdir '${CIX_WORKDIR}/build/zip/'
printf '42' > '${CIX_WORKDIR}/build/zip/${TEST_REP_NAME}-${TEST_VERSION}.zip'
" > "${CIX_WORKDIR}/assemble.sh"
chmod +x "${CIX_WORKDIR}/assemble.sh"

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKDIR="${CIX_WORKDIR}" \
 SIGNING_ALIAS="${TEST_ALIAS}" \
 "${SCRIPT}" "${TEST_REP_OWNER}" "${TEST_REP_NAME}" "${TEST_VARIANT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
