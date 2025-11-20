#! /bin/bash

PRGNAME="kio-extras"

### kio-extras (increase the functionality of the KDE resource)
# Добавляет дополнительные возможности и компоненты для увеличения
# функциональности KDE, например, компоненты для работы с файлами интернета

# Required:    kde-frameworks
#              kdsoap-ws-discovery-client
#              libproxy
#              plasma-activities-stats
#              qcoro
# Recommended: libkexiv2
# Optional:    libtirpc
#              samba
#              taglib
#              libappimage                  (https://github.com/AppImageCommunity/libappimage)
#              libimobiledevice             (https://libimobiledevice.org/)
#              libmtp                       (https://libmtp.sourceforge.net/)
#              libplist                     (https://github.com/libimobiledevice/libplist)
#              libssh                       (https://www.libssh.org/)
#              openexr                      (https://www.openexr.com/)

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
    -D BUILD_TESTING=OFF         \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (increase the functionality of the KDE resource)
#
# The kio-extras package contains additional components to increase the
# functionality of the KDE resource and network access abstractions
#
# Home page: https://github.com/KDE/${PRGNAME}
# Download:  https://download.kde.org/stable/release-service/${VERSION}/src/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
