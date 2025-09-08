#! /bin/bash

PRGNAME="kmod"

### Kmod (kernel module tools and library)
# Пакет содержит библиотеки и утилиты для загрузки модулей ядра

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr/sbin"

mkdir -p build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D manpages=false || exit 1

ninja || exit 1

# для набора тестов этого пакета требуются необработанные заголовки ядра (а не
# "продезинфицированные", которые были установленные ранее), что выходит за
# рамки LFS

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (kernel module tools and library)
#
# kmod is a set of tools to handle common tasks with Linux kernel modules like
# insert, remove, list, check properties, resolve dependencies and aliases. The
# aim is to be compatible with the tools, configurations and indexes from the
# module-init-tools project. These tools are designed on top of libkmod, a
# library that is shipped with kmod.
#
# Home page: https://www.kernel.org/
# Download:  https://www.kernel.org/pub/linux/utils/kernel/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
