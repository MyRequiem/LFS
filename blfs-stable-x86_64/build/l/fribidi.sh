#! /bin/bash

PRGNAME="fribidi"

### FriBidi (Unicode BiDirectional algorithm library)
# Библиотека реализует двунаправленный алгоритм Unicode, который необходим для
# поддержки языков с написанием справа налево, таких как арабский и иврит

# http://www.linuxfromscratch.org/blfs/view/9.0/general/fribidi.html

# Home page: http://fribidi.org
# Download:  https://github.com/fribidi/fribidi/releases/download/v1.0.5/fribidi-1.0.5.tar.bz2

# Required: no
# Optional: c2man (для сборки man-страниц)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# ninja test
ninja install
DESTDIR="${TMP_DIR}" ninja install

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Unicode BiDirectional algorithm library)
#
# This library implements the Unicode BiDirectional Algorithm (BIDI), which is
# needed in order to support right-to-left languages such as Arabic and Hebrew.
# It is used in display software like KDE's SVG modules.
#
# Home page: http://fribidi.org
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
