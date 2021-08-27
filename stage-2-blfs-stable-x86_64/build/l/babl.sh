#! /bin/bash

PRGNAME="babl"

### babl (pixel format translation library)
# Динамические библиотеки преобразования любого формата пикселей, а также
# фреймворк для добавления новых цветовых моделей и типов данных.

# Required:    no
# Recommended: gobject-introspection
#              librsvg
# Optional:    lcms2
#              w3m    (http://w3m.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

WITH_DOCS="false"

mkdir _build
cd _build || exit 1

meson                          \
    --prefix=/usr              \
    -Dwith-docs="${WITH_DOCS}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
