#! /bin/bash

PRGNAME="inih"

### inih.sh (INI Not Invented Here)
# Крошечная и быстрая библиотека на языке C для чтения конфигурационных файлов
# в формате INI (парсер .INI файлов). Идеально подходит для маленьких программ,
# которым нужно просто и надежно хранить свои настройки.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d r -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (INI Not Invented Here)
#
# inih (INI Not Invented Here)** is a simple .INI file parser written in C.
# It's only a couple of pages of code, and it was designed to be small and
# simple, so it's good for embedded systems. It's also more or less compatible
# with Python's ConfigParser style of .INI files, including RFC 822-style
# multi-line syntax and 'name: value' entries.
#
# Home page: https://github.com/benhoyt/${PRGNAME}
# Download:  https://github.com/benhoyt/${PRGNAME}/archive/r${VERSION}/${PRGNAME}-r${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
