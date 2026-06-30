#!/usr/local/bin/bash

SCRIPT='src/main/bash/gh/check_rates.sh'

echo "Running test for \"${SCRIPT}\"..."

. $asserts/files/execs.sh "${SCRIPT}"

if ! /usr/local/bin/bash -n "${SCRIPT}"; then
 echo "\"${SCRIPT}\" has invalid syntax!" >&2; exit 1; fi

STDOUT="$(mktemp)"
STDERR="$(mktemp)"

#

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Response error!\nGet limits error!\n'
rm -r "${CIX_SHARED}"

echo 'Not implemented!'; exit 1 # todo

#

rm "${STDOUT}"
rm "${STDERR}"
