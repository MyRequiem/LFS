#! /bin/bash

PRGNAME="gnome-bluetooth"

### GNOME Bluetooth (GNOME Bluetooth support)
# Набор инструментов для управления Bluetooth в среде рабочего стола GNOME.
# Позволяет подключать, настраивать и управлять различными
# Bluetooth-устройствами (например, наушниками, мышами, телефонами), отправлять
# и получать файлы, а также устанавливать сопряжение с устройствами. Приложения
# включают апплет в панели уведомлений, графический интерфейс в
# gnome-control-center и команду bluetooth-sendto для отправки файлов.

# Required:    gtk4
#              gsound
#              libnotify
#              upower
#              bluez                (runtime)
# Recommended: glib
#              libadwaita
# Optional:    gtk-doc
#              python3-dbusmock

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим ошибку сборки с python3-pygobject3 >=3.52.0
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-build_fix-1.patch" || exit 1

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
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Bluetooth support)
#
# The GNOME Bluetooth package contains tools for managing and manipulating
# Bluetooth devices using the GNOME Desktop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
