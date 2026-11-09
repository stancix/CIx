#!/usr/local/bin/bash

SUBJECT='build/yml/metadata.yml'
. $asserts/files/not_empty.sh "${SUBJECT}"

REP_GROUP="$(yq -Mer -p=yml -o=json '.repository.group' "${SUBJECT}")" || exit 1
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
| [Key](https://${REP_GROUP}.github.io/${REP_GROUP}_${SIGNING_ALIAS}.pub)"

EXPECTED_BUILD_AND_INSTALL="./assemble.sh --build_variant '${BUILD_VARIANT}' \\
 && ./src/test/bash/checks.sh --build_variant '${BUILD_VARIANT}' \\
 && mkdir '/opt/${REP_NAME}-${BUILD_VERSION}/' \\
 && tar -xf './build/tar/${REP_NAME}-${BUILD_VERSION}.tar.gz' -C '/opt/${REP_NAME}-${BUILD_VERSION}/'"

EXPECTED_DOWNLOAD_AND_INSTALL="TMP_PATH=\"\$(mktemp)\" \\
 && curl -m 32 -f -L 'https://github.com/${REP_OWNER}/${REP_NAME}/releases/download/${BUILD_VERSION}/${REP_NAME}-${BUILD_VERSION}.tar.gz' -o \"\${TMP_PATH}\" \\
 && mkdir '/opt/${REP_NAME}-${BUILD_VERSION}/' \\
 && tar -xf \"\${TMP_PATH}\" -C '/opt/${REP_NAME}-${BUILD_VERSION}/' && rm \"\${TMP_PATH}\""

EXPECTED_TEXTS=(
 "${EXPECTED_NAME}"
 "${EXPECTED_RELEASE}"
 "${EXPECTED_BUILD_AND_INSTALL}"
 "${EXPECTED_DOWNLOAD_AND_INSTALL}"
)
for EXPECTED_TEXT in "${EXPECTED_TEXTS[@]}"; do
 . $asserts/files/contains.sh "${SUBJECT}" "${EXPECTED_TEXT}"
done
