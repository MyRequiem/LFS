#! /bin/bash

PRGNAME="flameshot"

### Flameshot (screenshot software)
# Мощное, но простое в использовании программное обеспечение для создания
# скриншотов. Настраиваемый внешний вид, редактирование скриншотов, DBus
# интерфейс.

# Required:    cmake
#              python3-webencodings
#              python3-html5lib
#              md4c
#              nodejs
#              double-conversion
#              qt6
#              librsvg
#              libxkbcommon
# Recommended: no
# Optional:    git
#              openssh
#              p11-kit

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                                       \
    -D CMAKE_INSTALL_PREFIX=/usr            \
    -D CMAKE_BUILD_TYPE=Release             \
    -D BUILD_SHARED_LIBS=ON                 \
    -D BUILD_STATIC_LIBS=OFF                \
    -D KDSingleApplication_STATIC=OFF       \
    -D QTCOLORWIDGETS_BUILD_STATIC_LIBS=OFF \
    -W no-dev                               \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (screenshot software)
#
# Powerful yet simple to use screenshot software. Features: Customizable
# appearance. In-app screenshot edition. DBus interface.
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
