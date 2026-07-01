#!/usr/local/bin/bash

SCRIPT='src/main/bash/gh/checkout.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

VCS_REP_OWNER='stanuseless'
VCS_REP_NAME='Useless.Bash'
GITHUB_WORKER_PAT='foo'

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKDIR="$(mktemp -d)"
CIX_WORKDIR="${CIX_WORKDIR}" \
 VCS_REP_OWNER="${VCS_REP_OWNER}" \
 VCS_REP_NAME="${VCS_REP_NAME}" \
 VCS_SOURCE_COMMIT='5e20f9ebdf15c6302d383d45764ac52bc51e1c88' \
 VCS_TARGET_BRANCH='master' \
 GITHUB_WORKER_PAT="${GITHUB_WORKER_PAT}" \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
:> "${STDOUT}"
:> "${STDERR}"
git -C "${CIX_WORKDIR}" remote -v > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/not_empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
