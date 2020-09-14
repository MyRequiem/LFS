#! /bin/bash

PRGNAME="rpcsvc-proto"

### rpcsvc-proto (rpcsvc protocol.x files and headers)
# Пакет содержит файлы rpcsvc proto.x из glibc, которые отсутствуют в libtirpc.
# Дополнительно он содержит rpcgen, который необходим для создания заголовочных
# файлов и исходников из прото файлов. Этот пакет необходим только если glibc
# компилировалась без устаревшего sunrpc

# http://www.linuxfromscratch.org/blfs/view/stable/basicnet/rpcsvc-proto.html

# Home page: https://github.com/thkukuk/rpcsvc-proto
# Download:  https://github.com/thkukuk/rpcsvc-proto/releases/download/v1.4/rpcsvc-proto-1.4.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не содержит набота тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (rpcsvc protocol.x files and headers)
#
# This package contains rpcsvc proto.x files from glibc, which are missing in
# libtirpc. Additional it contains rpcgen, which is needed to create header
# files and sources from protocol files. This package is only needed, if glibc
# is installed without the deprecated sunrpc functionality and libtirpc should
# replace it.
#
# Home page: https://github.com/thkukuk/${PRGNAME}
# Download:  https://github.com/thkukuk/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
