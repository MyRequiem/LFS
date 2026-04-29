#! /bin/bash

PRGNAME="abseil-cpp"

### abseil-cpp (Abseil C++ Common Libraries)
# Огромная коллекция вспомогательного кода от инженеров Google, которая
# расширяет стандартные возможности языка C++. Она делает программы более
# стабильными, быстрыми и помогает избежать типичных ошибок программирования.

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                              \
    -D CMAKE_INSTALL_PREFIX=/usr   \
    -D CMAKE_BUILD_TYPE=Release    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -D ABSL_PROPAGATE_CXX_STD=ON   \
    -D BUILD_SHARED_LIBS=ON        \
    -G Ninja .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Abseil C++ Common Libraries)
#
# Abseil is an open-source collection of C++ code designed to augment the C++
# standard library.
#
# Home page: https://abseil.io
# Download:  https://github.com/abseil/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
