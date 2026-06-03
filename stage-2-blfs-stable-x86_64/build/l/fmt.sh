#! /bin/bash

PRGNAME="fmt"

### fmt (A modern formatting library)
# Современная и невероятно быстрая библиотека для безопасного форматирования
# текстовых строк и вывода данных в C++. Является удобной и надежной
# альтернативой классическим инструментам старого стандарта (stdio, printf и
# C++ iostreams).

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                                \
    -D CMAKE_INSTALL_PREFIX=/usr     \
    -D CMAKE_BUILD_TYPE=Release      \
    -D CMAKE_INSTALL_LIBDIR=/usr/lib \
    -D BUILD_SHARED_LIBS=ON          \
    -D FMT_TEST=OFF                  \
    -G Ninja .. || exit 1

ninja || exit 1

# тесты
# cmake -D FMT_TEST=ON .. &&
# ninja                   &&
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A modern formatting library)
#
# fmt is an open-source formatting library for C++. It can be used as a safe
# and fast alternative to (s)printf and iostreams.
#
# Home page: https://${PRGNAME}.dev/
# Download:  https://github.com/fmtlib/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
