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
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_EXIT_CODE=1 \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Request error!\n'
rm -r "${CIX_SHARED}"

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_HTTP_CODE=500 \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Response error!\n'
rm -r "${CIX_SHARED}"

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST='{"resources":{"core":{}}}' \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Check dst error!\n'
rm -r "${CIX_SHARED}"

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST='{"resources":{"core":{"limit":60}}}' \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Get remaining error!\n'
rm -r "${CIX_SHARED}"

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST='{"resources":{"core":{"limit":60,"remaining":8}}}' \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 1
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/equals.sh "${STDERR}" $'Remaining 8/60!\n'
rm -r "${CIX_SHARED}"

:> "${STDOUT}"
:> "${STDERR}"
CIX_SHARED="$(mktemp -d)"
PATH="${mocks}/curl/bin:${PATH}" \
 CIX_SHARED="${CIX_SHARED}" \
 MOCKS_CURL_HTTP_CODE=200 \
 MOCKS_CURL_DST='{"resources":{"core":{"limit":60,"remaining":42}}}' \
 "${SCRIPT}" > "${STDOUT}" 2> "${STDERR}"
. $asserts/ints/eq.sh "${SCRIPT}" "$?" 0
. $asserts/files/empty.sh "${STDOUT}"
. $asserts/files/empty.sh "${STDERR}"
rm -r "${CIX_SHARED}"

#

rm "${STDOUT}"
rm "${STDERR}"
