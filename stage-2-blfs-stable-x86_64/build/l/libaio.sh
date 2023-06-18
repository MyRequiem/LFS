#! /bin/bash

PRGNAME="libaio"

### libaio (asynchronous I/O library)
# Библиотека предоставляет встроенный в Linux API для асинхронного ввода-вывода
# (async I/O или aio). Такое API имеет более богатый набор возможностей, чем
# простой асинхронный ввод/вывод POSIX объектов.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключим установку статической библиотеки
sed -i '/install.*libaio.a/s/^/#/' src/Makefile || exit 1

make || exit 1

# для запуска тестов необходимо исправить проблему с glibc >=2.34
# sed 's/-Werror//' -i harness/Makefile
# make partcheck

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Download:  https://pagure.io/${PRGNAME}/archive/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
