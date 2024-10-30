#! /bin/bash

PRGNAME="orc"

### Orc (The Oil Runtime Compiler)
# Библиотека и набор инструментов для компиляции и выполнения очень простых
# программ, работающих с массивами данных.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                     \
    --prefix=/usr         \
    -Dorc-test=disabled   \
    -Dtests=disabled      \
    -Dgtk_doc=disabled    \
    -Dbenchmarks=disabled \
    -Dexamples=disabled   \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Oil Runtime Compiler)
#
# Orc is a library and set of tools for compiling and executing very simple
# programs that operate on arrays of data. The language is a generic assembly
# language that represents many of the features available in SIMD
# architectures, including saturated addition and subtraction, and many
# arithmetic operations.
#
# Home page: https://gstreamer.freedesktop.org/src/${PRGNAME}/
# Download:  https://gstreamer.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
