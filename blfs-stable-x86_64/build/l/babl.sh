#! /bin/bash

PRGNAME="babl"

### babl
# Библиотека преобразования пикселей между растровыми форматами (библиотека
# перевода в любой пиксельный формат)

# http://www.linuxfromscratch.org/blfs/view/9.0/general/babl.html

# Home page: http://gegl.org/babl/
# Download:  https://download.gimp.org/pub/babl/0.1/babl-0.1.70.tar.xz

# Required: lcms2
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# каталог build уже существует в дереве исходников, поэтому создаем директорию
# _build
mkdir _build
cd _build || exit 1

meson \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# ninja test
ninja install
DESTDIR="${TMP_DIR}" ninja install

# документация
DOCS="/usr/share/gtk-doc/html/babl"
install -v -m755 -d "${DOCS}/graphics"
install -v -m755 -d "${TMP_DIR}${DOCS}/graphics"

install -v -m644 docs/*.{css,html} "${DOCS}"
install -v -m644 docs/*.{css,html} "${TMP_DIR}${DOCS}"

install -v -m644 docs/graphics/*.{html,svg} "${DOCS}/graphics"
install -v -m644 docs/graphics/*.{html,svg} "${TMP_DIR}${DOCS}/graphics"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pixel format translation library)
#
# babl is a dynamic, any to any, pixel format translation library. It allows
# converting between different methods of storing pixels known as pixel formats
# that have with different bitdepths and other data representations, color
# models and component permutations. A vocabulary to formulate new pixel
# formats from existing primitives is provided as well as the framework to add
# new color models and data types.
#
# Home page: http://gegl.org/${PRGNAME}/
# Download:  https://download.gimp.org/pub/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
