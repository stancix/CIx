#!/usr/local/bin/bash

SCRIPT='src/main/bash/bash/checks.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

TEST_VARIANT='testvariant'
CIX_WORKDIR="$(mktemp -d)"
mkdir -p "${CIX_WORKDIR}/src/test/bash/" || exit 1
printf '%s' "[[ '--build_variant' == \"\$1\" && '${TEST_VARIANT}' == \"\$2\" ]] || exit 1" \
 > "${CIX_WORKDIR}/src/test/bash/checks.sh"
chmod +x "${CIX_WORKDIR}/src/test/bash/checks.sh"

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKDIR="${CIX_WORKDIR}" \
 "${SCRIPT}" --build_variant "${TEST_VARIANT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
