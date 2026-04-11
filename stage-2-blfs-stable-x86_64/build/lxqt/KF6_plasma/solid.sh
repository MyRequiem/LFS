#! /bin/bash

PRGNAME="solid"

### solid (device integration framework)
# Платформа интеграции устройств. Обеспечивает способ запроса и взаимодействие
# с оборудованием независимо от базовой операционной системы

# Required:    extra-cmake-modules
#              qt6
# Recommended: no
# Optional:    --- runtime ---
#              udisks
#              upower
#              libimobiledevice         (https://libimobiledevice.org/)
#              media-player-info        (http://www.freedesktop.org/wiki/Software/media-player-info)

###
# NOTE:
#    Нет необходимости в этом пакете, если установлен пакет kde-frameworks
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=Release         \
    -D CMAKE_INSTALL_LIBEXECDIR=libexec \
    -D KDE_INSTALL_USE_QT_SYS_PATHS=ON  \
    -D BUILD_TESTING=OFF                \
    -W no-dev                           \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (device integration framework)
#
# Solid is a device integration framework. It provides a way of querying and
# interacting with hardware independently of the underlying operating system
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/frameworks/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
