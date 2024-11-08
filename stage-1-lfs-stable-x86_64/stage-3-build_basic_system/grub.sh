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

###
# WARNING
###
# удалим все переменные среды, которые могут повлиять на сборку
unset {C,CPP,CXX,LD}FLAGS
# при сборке пакета Grub нельзя применять специальные флаги компиляции, т.к.
# низкоуровневые операции в исходном коде могут быть нарушены агрессивной
# оптимизацией

# добавим файл extra_deps.lst, отсутствующий в архиве исходников релиза
echo depends bli part_gpt > "${PRGNAME}-core/extra_deps.lst"

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

mv -v  "${TMP_DIR}/etc/bash_completion.d/${PRGNAME}" \
    "${TMP_DIR}${BASH_COMPLETION}"
rm -rf "${TMP_DIR}/etc/bash_completion.d"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

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
