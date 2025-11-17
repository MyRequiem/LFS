#! /bin/bash

PRGNAME="libkexiv2"

### libkexiv2 (wrapper library for exiv2)
# Оболочка для управления метаданными изображений посредством библиотеки Exiv2

# Required:    kde-frameworks
#              exiv2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D BUILD_WITH_QT6=ON         \
    -D BUILD_TESTING=OFF         \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (wrapper library for exiv2)
#
# Libkexiv2 is a KDE wrapper around the Exiv2 library for manipulating image
# metadata
#
# Home page: https://invent.kde.org/graphics/${PRGNAME}
# Download:  https://download.kde.org/stable/release-service/${VERSION}/src/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
