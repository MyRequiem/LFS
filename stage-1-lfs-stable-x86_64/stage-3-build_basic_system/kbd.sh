#! /bin/bash

PRGNAME="kbd"

### Kbd (keyboard maps and console fonts)
# Пакет содержит файлы раскладки (key-table), шрифты и утилиты для клавиатуры

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}${DOC_DIR}"

# поведение клавиш <Backspace> и <Delete> не одинаково для всех раскладок в
# пакете Kbd. Следующий патч исправляет эту проблему для i386 раскладки:
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-backspace-1.patch" || exit 1
# после применения патча клавиши <Backspace> и <Delete> генерируют символ с
# кодом 127

# не будем создавать утилиту resizecons, для которой требуется более
# неиспользуемая библиотека svgalib, a так же отключим созданием man-страницы
# для нее
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure      || exit 1
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in || exit 1

# предотвращает сборку утилиты vlock, так как она требует библиотеку PAM,
# которая не установлена в системе LFS
#    --disable-vlock
./configure       \
    --prefix=/usr \
    --disable-vlock || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}" || exit 1
    rm -rf usr/share/doc
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
# Home page: http://ftp.altlinux.org/pub/people/legion/${PRGNAME}
# Download:  https://www.kernel.org/pub/linux/utils/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
