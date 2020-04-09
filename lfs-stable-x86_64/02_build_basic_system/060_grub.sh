#! /bin/bash

PRGNAME="grub"

### GRUB
# Загрузчик GRand Unified Bootloader

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/grub.html

# Home page: http://www.gnu.org/software/grub/
# Download:  https://ftp.gnu.org/gnu/grub/grub-2.04.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
BASH_COMPLETION="/usr/share/bash-completion/completions"
mkdir -pv "${TMP_DIR}${BASH_COMPLETION}"

# позволяет не прерывать сборку при появлении предупреждений для более поздних
# версий Flex
#    --disable-werror
# минимизирует сборку, отключая некоторые особенности и тестирование программ,
# которые не нужны для LFS
#    --disable-efiemu
./configure           \
    --prefix=/usr     \
    --sbindir=/sbin   \
    --sysconfdir=/etc \
    --disable-efiemu  \
    --disable-werror || exit 1

make || exit 1
# пакет не содержит набора тестов, поэтому сразу устанавливаем
make install
make install DESTDIR="${TMP_DIR}"

BASH_COMPLETION_D="/etc/bash_completion.d"
mv -v   "${BASH_COMPLETION_D}/grub" "${BASH_COMPLETION}"
mv -v   "${TMP_DIR}${BASH_COMPLETION_D}/grub" "${TMP_DIR}${BASH_COMPLETION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the GRand Unified Bootloader)
#
# The GRand Unified Bootloader (GNU GRUB) is a multiboot boot loader.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
