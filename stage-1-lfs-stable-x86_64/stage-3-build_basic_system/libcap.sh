#! /bin/bash

PRGNAME="libcap"

### Libcap (get/set POSIX capabilities)
# Пакет реализует интерфейсы пользовательского пространства для POSIX 1003.1e
# возможностей, доступных в ядрах Linux. Эти возможности предоставляют
# разделение корневых привилегий в набор различных привилегий.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

# запретим установку статической библиотеки
sed -i '/install -m.*STA/d' libcap/Makefile

# собирать библиотеки с префиксом /lib, а не /lib64
#    lib=lib
make prefix=/usr lib=lib || make -j1 prefix=/usr lib=lib || exit 1

# make test

# установить библиотеку в $prefix/lib, а не в $prefix/lib64 и путь к директории
# pkgconfig
#    lib=lib PKGCONFIGDIR=...
make prefix=/usr lib=lib install DESTDIR="${TMP_DIR}"

# переместим библиотеки из /usr/lib в /lib и восстановим ссылки в /usr/lib
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
for LIBNAME in cap psx; do
    mv -v "${TMP_DIR}/usr/lib/lib${LIBNAME}.so."* "${TMP_DIR}/lib"
    ln -sfv "../../lib/lib${LIBNAME}.so.${MAJ_VERSION}" \
        "${TMP_DIR}/usr/lib/lib${LIBNAME}.so"
    chmod -v 755 "${TMP_DIR}/lib/lib${LIBNAME}.so.${VERSION}"
done

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (get/set POSIX capabilities)
#
# This is a library for getting and setting POSIX.1e (formerly POSIX 6) draft
# 15 capabilities. Package implements the user-space interfaces available in
# Linux kernels. These capabilities are a partitioning of the all powerful root
# privilege into a set of distinct privileges.
#
# Home page: https://sites.google.com/site/fullycapable/
# Download:  https://www.kernel.org/pub/linux/libs/security/linux-privs/${PRGNAME}${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
