#! /bin/bash

PRGNAME="flameshot"

### Flameshot (screenshot software)
# Мощное, но простое в использовании программное обеспечение для создания
# скриншотов. Настраиваемый внешний вид, редактирование скриншотов, DBus
# интерфейс, загрузка на Imgur (https://imgur.com)

# Required:    cmake
#              qt5-components
#              librsvg
#              libxkbcommon
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
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
# appearance. In-app screenshot edition. DBus interface. Upload to Imgur
# (https://imgur.com)
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
