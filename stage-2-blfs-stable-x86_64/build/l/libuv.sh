#! /bin/bash

PRGNAME="libuv"

### libuv (Unicorn Velociraptor Library)
# Многоплатформенная библиотека поддержки с акцентом на асинхронный ввод/вывод

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION=$(echo "${VERSION}" | cut -d v -f 2)
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sh autogen.sh
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Unicorn Velociraptor Library)
#
# libuv is a multi-platform C library that provides support for asynchronous
# I/O based on event loops. It supports epoll, kqueue, Windows IOCP, and
# Solaris event ports. It is primarily designed for use in Node.js but it is
# also used by other software projects. It was originally an abstraction around
# libev or Microsoft IOCP, as libev supports only select and doesn't support
# poll and IOCP on Windows. In node-v0.9.0's version of libuv, the dependency
# on libev was removed.
#
# Home page: https://libuv.org/
# Download:  https://dist.libuv.org/dist/v${VERSION}/${PRGNAME}-v${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
