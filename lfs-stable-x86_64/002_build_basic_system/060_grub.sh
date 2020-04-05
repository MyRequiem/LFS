#! /bin/bash

PRGNAME="grub"

### GRUB
# Загрузчик GRand Unified Bootloader

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/grub.html

# Home page: http://www.gnu.org/software/grub/
# Download:  https://ftp.gnu.org/gnu/grub/grub-2.04.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

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

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr/share/bash-completion/completions"
make install DESTDIR="${TMP_DIR}"

mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions/
rm -rf /etc/bash_completion.d
mv -v "${TMP_DIR}/etc/bash_completion.d/grub" \
    "${TMP_DIR}/usr/share/bash-completion/completions/"
rm -rf "${TMP_DIR}/etc/bash_completion.d"

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
