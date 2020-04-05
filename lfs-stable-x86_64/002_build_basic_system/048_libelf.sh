#! /bin/bash

PRGNAME="libelf"
ARCH_NAME="elfutils"

### Libelf from Elfutils
# Libelf - это библиотека для работы с файлами в формате ELF (Executable and
# Linkable Format)

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/libelf.html

# Home page: https://sourceware.org/ftp/elfutils/
# Download:  https://sourceware.org/ftp/elfutils/0.177/elfutils-0.177.tar.bz2

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
# устанавливаем только libelf
make -C libelf install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr/lib/pkgconfig"
make -C libelf install DESTDIR="${TMP_DIR}"

install -vm644 config/libelf.pc /usr/lib/pkgconfig
install -vm644 config/libelf.pc "${TMP_DIR}/usr/lib/pkgconfig"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for handling ELF)
#
# Libelf is a library for handling ELF (Executable and Linkable Format) files.
# Libelf is part of elfutils package.
#
# Home page: https://sourceware.org/ftp/${ARCH_NAME}/
# Download:  https://sourceware.org/ftp/${ARCH_NAME}/${VERSION}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
