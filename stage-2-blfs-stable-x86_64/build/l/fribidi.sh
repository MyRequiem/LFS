#! /bin/bash

PRGNAME="fribidi"

### FriBidi (Unicode BiDirectional algorithm library)
# Библиотека реализует двунаправленный алгоритм Unicode, который необходим для
# поддержки языков с написанием справа налево, таких как арабский и иврит

# Required:    no
# Recommended: no
# Optional:    c2man (для сборки man-страниц) http://www.ciselant.de/c2man/c2man.html

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Unicode BiDirectional algorithm library)
#
# This library implements the Unicode BiDirectional Algorithm (BIDI), which is
# needed in order to support right-to-left languages such as Arabic and Hebrew.
# It is used in display software like KDE's SVG modules.
#
# Home page: http://fribidi.org
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
