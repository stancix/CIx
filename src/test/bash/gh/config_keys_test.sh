#!/usr/local/bin/bash

SCRIPT='src/main/bash/gh/config_keys.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

CIX_WORKDIR="$(mktemp -d)"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $asserts/fail.sh 'Git init error!'

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKER_KEY_ID='2CFF9BD0725E548B'
CIX_WORKER_KEY='src/test/res/key.pgp'
CIX_WORKER_EMAIL='foo@bar.baz'
CIX_WORKDIR="${CIX_WORKDIR}" \
 "${SCRIPT}" "${CIX_WORKER_KEY_ID}" "${CIX_WORKER_KEY}" "${CIX_WORKER_EMAIL}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
