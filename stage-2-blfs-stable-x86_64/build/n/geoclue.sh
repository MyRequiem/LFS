#! /bin/bash

PRGNAME="geoclue"

### GeoClue (geoinformation service)
# Модульный геоинформационный сервис, построенный на базе D-Bus системы обмена
# сообщениями. Цель проекта - максимально просто создавать приложения
# определяющие местоположение.

# Required:    json-glib
#              libsoup3
# Recommended: avahi
#              libnotify
#              modemmanager
#              vala
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/geoclue/conf.d"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D gtk-doc=false    \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"

# для геолокации будем использовать службы геолокации Google
cat << EOF > "${TMP_DIR}/etc/geoclue/conf.d/90-lfs-google.conf"
# This configuration applies for the WiFi source
[wifi]

# Set the URL to Google's Geolocation Service.
#
# This API key is only intended for use with LFS. Please do not use this API
# key if you are building for another distro or distributing binary copies. If
# you need an API key, you can request one at
#    https://www.chromium.org/developers/how-tos/api-keys

url=https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDxKL42zsPjbke5O8_rPVpVrLrJ8aeE9rQ
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (geoinformation service)
#
# GeoClue is a modular geoinformation service built on top of the D-Bus
# messaging system. The goal of the GeoClue project is to make creating
# location-aware applications as simple as possible
#
# Home page: https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
