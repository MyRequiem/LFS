#! /bin/bash

PRGNAME="libaio"

### libaio
# Библиотека предоставляет встроенный в Linux API для асинхронного ввода-вывода
# (async I/O или aio). Такое API имеет более богатый набор возможностей, чем
# простой асинхронный ввод/вывод POSIX объектов.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libaio.html

# Home page: https://pagure.io/libaio
# Download:  https://releases.pagure.org/libaio/libaio-0.3.112.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# отключим установку статической библиотеки
sed -i '/install.*libaio.a/s/^/#/' src/Makefile || exit 1

make
# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (asynchronous I/O library)
#
# The Linux-native asynchronous I/O facility ("async I/O", or "aio") has a
# richer API and capability set than the simple POSIX async I/O facility. This
# library provides the Linux-native API for async I/O. The POSIX async I/O
# facility requires this library in order to provide kernel-accelerated async
# I/O capabilities, as do applications which require the Linux-native async I/O
# API.
#
# Home page: https://pagure.io/${PRGNAME}
# Download:  https://releases.pagure.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
