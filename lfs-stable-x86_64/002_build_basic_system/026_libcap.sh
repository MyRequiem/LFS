#! /bin/bash

PRGNAME="libcap"

### Libcap
# Пакет реализует интерфейсы пользовательского пространства для POSIX 1003.1e
# возможностей, доступных в ядрах Linux. Эти возможности предоставляют
# разделение корневых привилегий в набор различных привилегий.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/libcap.html

# Home page: https://sites.google.com/site/fullycapable/
# Download:  https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.27.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# запретим установку статической библиотеки
sed -i '/install.*STALIBNAME/d' libcap/Makefile

make || exit 1

# в этот пакет не входит набор тестов, поэтому сразу устанавливаем

# избегаем ошибок установки, если ядро или файловая система не поддерживают
# расширенные возможности
#    RAISE_SETFCAP=no
# установить библиотеку в $prefix/lib, а не в $prefix/lib64
#    lib=lib
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 "/usr/lib/libcap.so.${VERSION}"

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"
make RAISE_SETFCAP=no lib=lib prefix="${TMP_DIR}/usr" install
chmod -v 755 "${TMP_DIR}/usr/lib/libcap.so.${VERSION}"

# библиотеку необходимо переместить из /usr/lib в /lib
mv -v /usr/lib/libcap.so.* /lib
mv -v "${TMP_DIR}/usr/lib"/libcap.so.* "${TMP_DIR}/lib"

# воссоздадим ссылку libcap.so в /usr/lib
# libcap.so -> ../../lib/libcap.so.2
ln -sfv "../../lib/$(readlink /usr/lib/libcap.so)" /usr/lib/libcap.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libcap.so)" libcap.so
)

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
