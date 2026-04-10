#! /bin/bash

PRGNAME="grub"

### GRUB (the GRand Unified Bootloader)
# Системный загрузчик, который запускается первым при включении компьютера и
# позволяет выбрать и загрузить операционную систему для работы.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

###
# WARNING
###
# Удалим все переменные среды, которые могут повлиять на сборку. При сборке
# пакета Grub нельзя применять специальные флаги компиляции, т.к.
# низкоуровневые операции в исходном коде могут быть нарушены агрессивной
# оптимизацией.
unset {C,CPP,CXX,LD}FLAGS

# исправим ошибку, появившуюся в grub-2.14
sed 's/--image-base/--nonexist-linker-option/' -i configure || exit 1

# минимизирует сборку, отключая некоторые особенности и тестирование программ,
# которые не нужны для LFS
#    --disable-efiemu
# позволяет не прерывать сборку при появлении предупреждений для более поздних
# версий Flex
#    --disable-werror
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-efiemu  \
    --disable-werror || exit 1

make || make -j1 || exit 1

# запускать набор тестов для этого пакета не рекомендуется
# make check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the GRand Unified Bootloader)
#
# The GRand Unified Bootloader (GNU GRUB) is a multiboot boot loader.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
