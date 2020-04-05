#! /bin/bash

PRGNAME="kmod"

### Kmod
# Пакет содержит библиотеки и утилиты для загрузки модулей ядра

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/kmod.html

# Home page: https://www.kernel.org/
# Download:  https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-26.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

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

make || exit 1
# пакет поставляется без набора тестов, которые можно запустить в среде chroot,
# поэтому сразу устанавливаем его
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/sbin"
make install DESTDIR="${TMP_DIR}"

# создадим символические ссылки в /sbin для совместимости с Module-Init-Tools
# (пакет, который ранее работал с модулями ядра)
# depmod -> ../bin/kmod
# insmod -> ../bin/kmod
# ...
for TARGET in depmod insmod lsmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod "/sbin/${TARGET}"
    (
        cd "${TMP_DIR}/sbin" || exit 1
        ln -sfv ../bin/kmod "${TARGET}"
    )
done

# ссылка в /bin lsmod -> kmod
ln -sfv kmod /bin/lsmod
(
    cd "${TMP_DIR}/bin" || exit 1
    ln -sfv kmod lsmod
)

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
