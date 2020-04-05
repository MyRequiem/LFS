#! /bin/bash

PRGNAME="libuv"

### libuv (Unicorn Velociraptor Library)
# Многоплатформенная библиотека поддержки с акцентом на асинхронный ввод/вывод

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libuv.html

# Home page: https://libuv.org/
#            https://github.com/libuv/libuv
# Download:  https://dist.libuv.org/dist/v1.31.0/libuv-v1.31.0.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION=$(echo "${VERSION}" | cut -d v -f 2)
TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

sh autogen.sh
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

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
#            https://github.com/libuv/libuv
# Download:  https://dist.libuv.org/dist/v1.31.0/libuv-v1.31.0.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
