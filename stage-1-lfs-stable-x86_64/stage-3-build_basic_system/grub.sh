#! /bin/bash

PRGNAME="grub"

### GRUB (the GRand Unified Bootloader)
# Загрузчик GRand Unified Bootloader

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
BASH_COMPLETION="/usr/share/bash-completion/completions"
mkdir -pv "${TMP_DIR}${BASH_COMPLETION}"

# исправим проблему, вызванную binutils-2.36
sed "s/gold-version/& -R .note.gnu.property/" \
    -i Makefile.in grub-core/Makefile.in || exit 1

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

make || make -j1 || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

mv -v "${TMP_DIR}/etc/bash_completion.d/grub" "${TMP_DIR}${BASH_COMPLETION}"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the GRand Unified Bootloader)
#
# The GRand Unified Bootloader (GNU GRUB) is a multiboot boot loader.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
