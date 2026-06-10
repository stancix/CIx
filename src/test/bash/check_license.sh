#!/usr/local/bin/bash

ISSUER='LICENSE'
if [[ ! -f "${ISSUER}" ]]; then
 echo "No file \"${ISSUER}\"!"; exit 1
elif [[ ! -s "${ISSUER}" ]]; then
 echo "File \"${ISSUER}\" is empty!"; exit 1
fi

AUTHOR='Stanley Wintergreen'
REGEX="Copyright 2[0-9]{3} ${AUTHOR}"

if ! grep -qE "${REGEX}" "${ISSUER}"; then
 echo "File \"${ISSUER}\" does not satisfy the regex:
---
${REGEX}
---"; exit 1; fi
