#! /bin/bash

PRGNAME="libcap"

### Libcap
# Пакет реализует интерфейсы пользовательского пространства для POSIX 1003.1e
# возможностей, доступных в ядрах Linux. Эти возможности предоставляют
# разделение корневых привилегий в набор различных привилегий.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libcap.html

# Home page: https://sites.google.com/site/fullycapable/
# Download:  https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.31.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

# запретим установку двух статических библиотек
sed -i '/install.*STA...LIBNAME/d' libcap/Makefile || exit 1

# собирать библиотеки с префиксом /lib, а не /lib64
#    lib=lib
make lib=lib || exit 1
make test
# избегаем ошибок установки, если ядро или файловая система не поддерживают
# расширенные возможности
#    RAISE_SETFCAP=no
# установить библиотеку в $prefix/lib, а не в $prefix/lib64
#    lib=lib
make lib=lib install
make lib=lib install DESTDIR="${TMP_DIR}"

chmod -v 755 "/lib/libcap.so.${VERSION}"
chmod -v 755 "${TMP_DIR}/lib/libcap.so.${VERSION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (get/set POSIX capabilities)
#
# This is a library for getting and setting POSIX.1e (formerly POSIX 6) draft
# 15 capabilities. Package implements the user-space interfaces available in
# Linux kernels. These capabilities are a partitioning of the all powerful root
# privilege into a set of distinct privileges.
#
# Home page: https://sites.google.com/site/fullycapable/
# Download:  https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
