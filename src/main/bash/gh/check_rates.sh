#!/usr/local/bin/bash

SUBJECT='.cix/gh-limits.json'

$ghx/rate_limit.sh "${SUBJECT}" \
 || $checks/fail.sh 'Get limits error!'

CIX_LIMIT="$(yq -Me -p=json -o=json '.resources.core.limit' "${SUBJECT}")" \
 || $checks/fail.sh 'Get limit error!'

CIX_REMAINING="$(yq -Me -p=json -o=json '.resources.core.remaining' "${SUBJECT}")" \
 || $checks/fail.sh 'Get remaining error!'

. $checks/ints/gt.sh "${CIX_REMAINING}" 30 "Remaining ${CIX_REMAINING}/${CIX_LIMIT}!"
