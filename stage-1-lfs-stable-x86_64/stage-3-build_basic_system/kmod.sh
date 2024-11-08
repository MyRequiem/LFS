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

# позволяет Kmod обрабатывать подписи PKCS7 для модулей ядра
#    --with-openssl
# опции позволяют Kmod обрабатывать сжатые модули ядра
#    --with-xz
#    --with-zstd
#    --with-zlib
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --with-openssl    \
    --with-xz         \
    --with-zstd       \
    --with-zlib       \
    -disable-manpages || exit 1

make || make -j1 || exit 1

# для набора тестов этого пакета требуются необработанные заголовки ядра (а не
# "продезинфицированные", которые были установленные ранее), что выходит за
# рамки LFS

make install DESTDIR="${TMP_DIR}"

# для совместимости с Module-Init-Tools (пакет, который ранее работал с
# модулями ядра) создадим символические ссылки в /usr/sbin/
#    depmod -> ../bin/kmod
#    insmod -> ../bin/kmod
#    и т.д.
for TARGET in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod "${TMP_DIR}/usr/sbin/${TARGET}"
done

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
