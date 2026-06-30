#! /bin/bash

PRGNAME="babl"

### babl (pixel format translation library)
# Специализированный графический модуль, который отвечает за точное и быстрое
# преобразование пикселей между различными цветовыми форматами. Он является
# ключевой деталью для редактора GEGL.

# Required:    no
# Recommended: glib
#              librsvg
#              lcms2
# Optional:    w3m          (http://w3m.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir bld
cd bld || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D with-docs=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: https://gegl.org/${PRGNAME}/
# Download:  https://download.gimp.org/pub/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
