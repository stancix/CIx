#!/usr/local/bin/bash

SCRIPT='src/main/bash/git/merge.sh'

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

CIX_WORKDIR="$(mktemp -d)"
VCS_SRC_COMMIT='3f964efe91de6ff69cd630f59fd6c6a811dab76a'
VCS_DST_BRANCH='test_dst'
VCS_URL="https://github.com/${VCS_REP_OWNER}/${VCS_REP_NAME}.git"

git -C "${CIX_WORKDIR}" init --quiet \
 || . $asserts/fail.sh 'Git init error!'

git -C "${CIX_WORKDIR}" remote add origin "${VCS_URL}" \
 || . $asserts/fail.sh 'Git remotes error!'

git -C "${CIX_WORKDIR}" fetch origin "${VCS_DST_BRANCH}" --quiet \
 || . $asserts/fail.sh "Git fetch \"${VCS_DST_BRANCH}\" error!"

git -C "${CIX_WORKDIR}" fetch origin "${VCS_SRC_COMMIT}" --quiet \
 || . $asserts/fail.sh "Git fetch \"${VCS_SRC_COMMIT}\" error!"

git -C "${CIX_WORKDIR}" switch "${VCS_DST_BRANCH}" --quiet \
 || . $asserts/fail.sh "Git switch \"${VCS_DST_BRANCH}\" error!"

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
