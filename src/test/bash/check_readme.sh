#!/usr/local/bin/bash

SUBJECT='build/yml/metadata.yml'
. $asserts/files/not_empty.sh "${SUBJECT}"

REP_OWNER="$(yq -Mer -p=yml -o=json '.repository.owner' "${SUBJECT}")" || exit 1
REP_NAME="$(yq -Mer -p=yml -o=json '.repository.name' "${SUBJECT}")" || exit 1
BUILD_VARIANT="$(yq -Mer -p=yml -o=json '.build.variant' "${SUBJECT}")" || exit 1
BUILD_VERSION="$(yq -Mer -p=yml -o=json '.build.version' "${SUBJECT}")" || exit 1
SIGNING_ALIAS="$(yq -Mer -p=yml -o=json '.signing.alias' "${SUBJECT}")" || exit 1

SUBJECT='README.md'
. $asserts/files/not_empty.sh "${SUBJECT}"

EXPECTED_NAME="# ${REP_NAME}"

EXPECTED_RELEASE="\`${BUILD_VERSION}\`
| [GitHub](https://github.com/${REP_OWNER}/${REP_NAME}/releases/tag/${BUILD_VERSION})
| [Key](https://${REP_OWNER}.github.io/${SIGNING_ALIAS}-public.pem)"

EXPECTED_BUILD_AND_INSTALL="$ ./assemble.sh '${BUILD_VARIANT}' \\
 && ./src/test/bash/checks.sh '${BUILD_VARIANT}' \\
 && unzip -d /opt/${REP_NAME}-${BUILD_VERSION} ./build/zip/${REP_NAME}-${BUILD_VERSION}.zip"

EXPECTED_DOWNLOAD_AND_INSTALL="$ TMP_PATH=\"\$(mktemp)\"; \\
 curl -L 'https://github.com/${REP_OWNER}/${REP_NAME}/releases/download/${BUILD_VERSION}/${REP_NAME}-${BUILD_VERSION}.zip' \\
  -o \"\${TMP_PATH}\" && unzip -d /opt/${REP_NAME}-${BUILD_VERSION} \"\${TMP_PATH}\" && rm \"\${TMP_PATH}\""

EXPECTED_TEXTS=(
 "${EXPECTED_NAME}"
 "${EXPECTED_RELEASE}"
 "${EXPECTED_BUILD_AND_INSTALL}"
 "${EXPECTED_DOWNLOAD_AND_INSTALL}"
)
for EXPECTED_TEXT in "${EXPECTED_TEXTS[@]}"; do
 . $asserts/files/contains.sh "${SUBJECT}" "${EXPECTED_TEXT}"
done
