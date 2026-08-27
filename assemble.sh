#!/usr/local/bin/bash

if [[ $# -ne 1 ]]; then
 echo 'Wrong arguments!' >&2; exit 1; fi

REP_OWNER='stancix'
REP_NAME='CIx'
VERSION_NAME='0.1.5'

BUILD_VARIANT="$1"
case "${BUILD_VARIANT}" in
 'unstable')
  BUILD_VERSION="${VERSION_NAME}-UNSTABLE"
  SIGNING_ALIAS='debug'
 ;;
 '') echo 'No build variant!' >&2; exit 1;;
 *) echo "Build variant \"${BUILD_VARIANT}\" is not supported!" >&2; exit 1;;
esac

if [[ -d 'build' ]]; then
 echo 'Build dir exists!' >&2; exit 1; fi

mkdir 'build'
mkdir -p 'build/yml'
SUBJECT='build/yml/metadata.yml'
echo "\
repository:
 owner: '${REP_OWNER}'
 name: '${REP_NAME}'
build:
 variant: '${BUILD_VARIANT}'
 version: '${BUILD_VERSION}'
signing:
 alias: '${SIGNING_ALIAS}'
" > "${SUBJECT}"

if [[ ! -s 'LICENSE' ]]; then
 echo 'No license!' >&2; exit 1; fi

if [[ ! -s 'README.md' ]]; then
 echo 'No readme!' >&2; exit 1; fi

mkdir -p 'build/zip'
SUBJECT="build/zip/${REP_NAME}-${BUILD_VERSION}.zip"
zip -Xqr9 "${SUBJECT}" 'src/main/bash' 'LICENSE' 'README.md'
if [[ $? -ne 0 ]]; then
 echo 'Zip error!' >&2; exit 1; fi
