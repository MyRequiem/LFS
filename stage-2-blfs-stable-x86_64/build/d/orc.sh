#! /bin/bash

PRGNAME="orc"

### Orc (The Oil Runtime Compiler)
# Компилятор, который автоматически оптимизирует обработку больших массивов
# данных прямо во время работы программы. Он использует скрытые возможности
# процессора для ускорения работы с аудио и видео.

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

meson setup ..             \
    --prefix=/usr          \
    --buildtype=release    \
    -D tests=disabled      \
    -D benchmarks=disabled \
    -D examples=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
