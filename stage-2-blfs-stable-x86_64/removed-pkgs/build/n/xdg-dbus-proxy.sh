#! /bin/bash

PRGNAME="xdg-dbus-proxy"

### xdg-dbus-proxy (filtering proxy for D-Bus connections)
# Прокси-сервер для фильтрации соединений D-Bus. Полезно для пересылки данных в
# песочницу и из нее

# Required:    glib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (filtering proxy for D-Bus connections)
#
# The xdg-dbus-proxy package contains a filtering proxy for D-Bus connections.
# This is useful for forwarding data in and out of a sandbox
#
# Home page: https://github.com/flatpak/${PRGNAME}/
# Download:  https://github.com/flatpak/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
