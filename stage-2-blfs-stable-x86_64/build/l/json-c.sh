#! /bin/bash

PRGNAME="json-c"

### JSON-C (JSON library in C)
# Реализует объектную модель подсчета ссылок, которая позволяет легко
# конструировать объекты JSON в C, выводить их как строки в формате JSON и
# анализировать строки в JSON-формате обратно в C-представление объектов JSON

# Required:    cmake
# Recommended: no
# Optional:    --- для документации ---
#              doxygen
#              graphviz

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с CMake-4.0
sed -i 's/VERSION 2.8/VERSION 4.0/' apps/CMakeLists.txt  || exit 1
sed -i 's/VERSION 3.9/VERSION 4.0/' tests/CMakeLists.txt || exit 1

mkdir build
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    -DBUILD_STATIC_LIBS=OFF     \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (JSON library in C)
#
# The JSON-C implements a reference counting object model that allows you to
# easily construct JSON objects in C, output them as JSON formatted strings and
# parse JSON formatted strings back into the C representation of JSON objects.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://s3.amazonaws.com/${PRGNAME}_releases/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
