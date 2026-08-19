#!/usr/local/bin/bash

SCRIPT='src/main/bash/gh/init.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

VCS_REP_OWNER='stanuseless'
VCS_REP_NAME='Useless.Bash'

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKDIR="$(mktemp -d)"
CIX_WORKDIR="${CIX_WORKDIR}" \
 VCS_SRC_COMMIT='3f964efe91de6ff69cd630f59fd6c6a811dab76a' \
 VCS_DST_BRANCH='test_dst' \
 "${SCRIPT}" "${VCS_REP_OWNER}" "${VCS_REP_NAME}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"

:> "${STDOUT}"
:> "${STDERR}"
git -C "${CIX_WORKDIR}" remote -v > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
STDOUT_EXPECTED="\
origin	https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git (fetch)
origin	https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git (push)
"
. $asserts/files/equals.sh "${STDOUT}" "${STDOUT_EXPECTED}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
