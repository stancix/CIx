#!/usr/local/bin/bash

SCRIPT='src/main/bash/git/merge.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

CIX_WORKDIR="$(mktemp -d)"
VCS_SRC_BRANCH='test_src'
VCS_DST_BRANCH='test_dst'

git -C "${CIX_WORKDIR}" init --quiet \
 && git -C "${CIX_WORKDIR}" config user.name 'foo' --quiet \
 && git -C "${CIX_WORKDIR}" config user.email 'foo@mail.org' --quiet \
 || . $asserts/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" checkout -b "${VCS_DST_BRANCH}" --quiet \
 || . $asserts/fail.sh "Git checkout \"${VCS_DST_BRANCH}\" error!"

printf '%s' 'foo' > "${CIX_WORKDIR}/foo.txt"

git -C "${CIX_WORKDIR}" add . \
 && git -C "${CIX_WORKDIR}" commit -m 'foo' --quiet \
 || . $asserts/fail.sh "Git commit error!"

git -C "${CIX_WORKDIR}" checkout -b "${VCS_SRC_BRANCH}" --quiet \
 || . $asserts/fail.sh "Git checkout \"${VCS_SRC_BRANCH}\" error!"

printf '%s' 'bar' > "${CIX_WORKDIR}/bar.txt"

git -C "${CIX_WORKDIR}" add . \
 && git -C "${CIX_WORKDIR}" commit -m 'bar' --quiet \
 || . $asserts/fail.sh "Git commit error!"

VCS_SRC_COMMIT="$(git -C "${CIX_WORKDIR}" rev-parse HEAD)"

git -C "${CIX_WORKDIR}" switch "${VCS_DST_BRANCH}" --quiet \
 || . $asserts/fail.sh "Git switch \"${VCS_DST_BRANCH}\" error!"

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_WORKDIR="${CIX_WORKDIR}" \
 VCS_SRC_COMMIT="${VCS_SRC_COMMIT}" \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -rf "${CIX_WORKDIR}"

#

rm "${STDOUT}"
rm "${STDERR}"
