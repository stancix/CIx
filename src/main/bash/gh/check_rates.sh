#!/usr/local/bin/bash

SUBJECT="${CIX_SHARED}/gh_limits.json"

. $ghx/rate_limit.sh "${SUBJECT}"

CIX_LIMIT="$(yq -Me -p=json -o=json '.resources.core.limit' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get limit error!'

CIX_REMAINING="$(yq -Me -p=json -o=json '.resources.core.remaining' "${SUBJECT}" 2> /dev/null)" \
 || . $checks/fail.sh 'Get remaining error!'

. $checks/ints/gt.sh "${CIX_REMAINING}" 30 "Remaining ${CIX_REMAINING}/${CIX_LIMIT}!"
