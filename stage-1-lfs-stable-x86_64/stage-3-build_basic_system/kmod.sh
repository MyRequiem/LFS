#! /bin/bash

PRGNAME="kmod"

### Kmod (kernel module tools and library)
# Пакет содержит библиотеки и утилиты для загрузки модулей ядра

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/kmod.html

# Home page: https://www.kernel.org/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/sbin"

# опции позволяют Kmod обрабатывать сжатые модули ядра
#    --with-xz
#    --with-zlib
# гарантирует, что файлы, относящиеся к разным библиотекам, будут размещены в
# правильных каталогах
#    --with-rootlibdir=/lib
./configure                \
    --prefix=/usr          \
    --bindir=/bin          \
    --sysconfdir=/etc      \
    --with-rootlibdir=/lib \
    --with-xz              \
    --with-zlib || exit 1

make || make -j1 || exit 1

# пакет поставляется без набора тестов, которые можно запустить в среде chroot

make install DESTDIR="${TMP_DIR}"

# для совместимости с Module-Init-Tools (пакет, который ранее работал с
# модулями ядра) создадим символические ссылки в /sbin
#    depmod -> ../bin/kmod
#    insmod -> ../bin/kmod
#    и т.д.
(
    cd "${TMP_DIR}/sbin" || exit 1
    for TARGET in depmod insmod lsmod modinfo modprobe rmmod; do
        ln -sfv ../bin/kmod "${TARGET}"
    done
)

# ссылка в /bin lsmod -> kmod
ln -sfv kmod "${TMP_DIR}/bin/lsmod"

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
