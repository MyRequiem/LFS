#! /bin/bash

PRGNAME="kbd"

### Kbd (keyboard maps and console fonts)
# Пакет для настройки клавиатуры в текстовой консоли Linux (TTY), включая выбор
# раскладки языков и установку экранных шрифтов.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}${DOC_DIR}"

# поведение клавиш <Backspace> и <Delete> не одинаково для всех раскладок в
# пакете Kbd. Следующий патч исправляет эту проблему для i386 раскладки - после
# его применения клавиши <Backspace> и <Delete> генерируют символ с кодом 127
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-backspace-1.patch" || exit 1

# не будем создавать утилиту resizecons, для которой требуется более
# неиспользуемая библиотека svgalib, a так же отключим созданием man-страницы
# для нее
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure      || exit 1
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in || exit 1

# vlock - утилита блокирует виртуальную консоль (TTY), требуя пароль текущего
# пользователя для возврата к работе. Для сборки требуется libpam.so (пакет
# linux-pam из BLFS). Не будем ее компилировать за ненадобностью, есть много
# других способов заблокировать консоль.
#    --disable-vlock
./configure       \
    --prefix=/usr \
    --disable-vlock || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (keyboard maps and console fonts)
#
# The Kbd package contains key-table files, console fonts, and keyboard
# utilities. Load and save keyboard mappings. Needed if you are not using the
# US keyboard map. This package also contains utilities to change your console
# fonts - if you install it you'll get a menu later on that lets you select
# from many different fonts. If you like one, you can make it your default
# font. A new default font can be chosen at any time by typing
# 'setconsolefont'.
#
# Home page: https://www.kernel.org/pub/linux/utils/${PRGNAME}/
# Download:  https://www.kernel.org/pub/linux/utils/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
