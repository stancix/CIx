#!/usr/local/bin/bash

REP_GROUP='stanprojects'
REP_OWNER='stancix'
REP_NAME='CIx'
VERSION_NAME='0.2.2'

unset BUILD_VARIANT
unset BUILD_WORKDIR

while [[ $# -gt 0 ]]; do
 if [[ $# -lt 2 ]]; then echo 'Wrong flags!' >&2; exit 1; fi
 case "$1" in
  '--build_variant')
   if [[ -v BUILD_VARIANT ]]; then echo "\"$1\" already used!" >&2; exit 1; fi
   BUILD_VARIANT="$2"; shift 2;;
  '--workdir')
   if [[ -v BUILD_WORKDIR ]]; then echo "\"$1\" already used!" >&2; exit 1; fi
   BUILD_WORKDIR="$2"; shift 2;;
  *) echo "\"$1\" is not supported!" >&2; exit 1;;
 esac
done

#

case "${BUILD_VARIANT}" in
 'unstable') BUILD_VERSION="${VERSION_NAME}-UNSTABLE"
  SIGNING_ALIAS='debug';;
 'release') BUILD_VERSION="${VERSION_NAME}"
  SIGNING_ALIAS='release';;
 '') echo 'No build variant!' >&2; exit 1;;
 *) echo "Build variant \"${BUILD_VARIANT}\" is not supported!" >&2; exit 1;;
esac

#

if [[ ! -v BUILD_WORKDIR ]]; then
 BUILD_WORKDIR="$(pwd)"
 if [[ $? != 0 ]]; then echo 'Get workdir error!' >&2; exit 1; fi
fi

if [[ -z "${BUILD_WORKDIR}" ]]; then
 echo 'No workdir!' >&2; exit 1
elif [[ -L "${BUILD_WORKDIR}" ]]; then
 echo "\"${BUILD_WORKDIR}\" is a symlink!" >&2; exit 1
fi

BUILD_WORKDIR="$(realpath -- "${BUILD_WORKDIR}")"
if [[ $? != 0 ]]; then
 echo 'Realpath workdir error!' >&2; exit 1
elif [[ ! -e "${BUILD_WORKDIR}" ]]; then
 echo "\"${BUILD_WORKDIR}\" does not exist!" >&2; exit 1
elif [[ ! -d "${BUILD_WORKDIR}" ]]; then
 echo "\"${BUILD_WORKDIR}\" is not a dir!" >&2; exit 1
fi

#

if [[ -d "${BUILD_WORKDIR}/build/" ]];
 then echo 'Build dir exists!' >&2; exit 1; fi

mkdir "${BUILD_WORKDIR}/build/"
mkdir -p "${BUILD_WORKDIR}/build/yml/"
SUBJECT="${BUILD_WORKDIR}/build/yml/metadata.yml"
echo "\
repository:
 group: '${REP_GROUP}'
 owner: '${REP_OWNER}'
 name: '${REP_NAME}'
build:
 variant: '${BUILD_VARIANT}'
 version: '${BUILD_VERSION}'
signing:
 alias: '${SIGNING_ALIAS}'
" > "${SUBJECT}"

if [[ ! -s "${BUILD_WORKDIR}/LICENSE" ]]; then
 echo 'No license!' >&2; exit 1; fi

if [[ ! -s "${BUILD_WORKDIR}/README.md" ]]; then
 echo 'No readme!' >&2; exit 1; fi

#

mkdir -p "${BUILD_WORKDIR}/build/tar/"
SUBJECT="${BUILD_WORKDIR}/build/tar/${REP_NAME}-${BUILD_VERSION}.tar.gz"

(BASH_XTRACEFD=1; set -x; cd "${BUILD_WORKDIR}" \
 && tar -czf "${SUBJECT}" './src/main/bash/' './LICENSE' './README.md')
if [[ $? != 0 ]]; then echo "Tar ${REP_NAME}-${BUILD_VERSION} error!" >&2; exit 1; fi
