#! /bin/bash

PRGNAME="cairomm114"

### cairomm (C++ wrapper for the cairo graphics library)
# C++ интерфейс для графической библиотеки cairo

# Required:    cairo
#              libsigc++2
# Recommended: boost        (для тестов)
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

TESTS="false"
EXAMPLES="false"
DOCS="false"

mkdir bld &&
cd bld || exit 1

meson                               \
    --prefix=/usr                   \
    --buildtype=release             \
    -Dbuild-tests="${TESTS}"        \
    -Dboost-shared=true             \
    -Dbuild-examples="${EXAMPLES}"  \
    -Dbuild-documentation="${DOCS}" \
      .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ wrapper for the cairo graphics library)
#
# cairomm is a C++ wrapper (C++ interface) for the cairo graphics library. It
# offers all the power of cairo with an interface familiar to C++ developers,
# including use of the Standard Template Library where it makes sense.
#
# Home page: https://www.cairographics.org/${PRGNAME}/
# Download:  https://www.cairographics.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
