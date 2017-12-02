#!/usr/bin/env bash
set -e

BUSYBOX_VERSION=${BUSYBOX_VERSION:-"1.27.1"}
BUSYBOX_ARCH=${BUSYBOX_ARCH:-"i686"}

NIX_ROOT=${NIX_ROOT:-"${HOME}/.nix"}
CURL_PATH=${CURL_PATH:-$(readlink -f $(which curl))}


mkdir -pv ${NIX_ROOT}/bin
cp ${CURL_PATH} ${NIX_ROOT}/bin/curl
for f in $(ldd ${CURL_PATH} | cut -d'>' -f2 | awk '{print $1}'); do [ -f ${f} ] && rf=`readlink -f ${f}`; mkdir -pv ${NIX_ROOT}`dirname ${f}` && cp -v ${rf} ${NIX_ROOT}${f}; done

mkdir -pv ${NIX_ROOT}/bin/bbdir
cd ${NIX_ROOT}/bin/bbdir
${CURL_PATH} -LO https://www.busybox.net/downloads/binaries/${BUSYBOX_VERSION}-${BUSYBOX_ARCH}/busybox
