#! /bin/bash

PRGNAME="nautilus"

### Nautilus (GNOME file manager)
# Стандартный файловый менеджер для среды рабочего стола GNOME

# Required:    bubblewrap
#              gexiv2
#              gnome-autoar
#              gnome-desktop
#              libadwaita
#              libnotify
#              libportal
#              libseccomp
#              tinysparql
# Recommended: desktop-file-utils
#              exempi
#              glib
#              gst-plugins-base
#              libcloudproviders
#              libexif
#              --- runtime ---
#              adwaita-icon-theme
#              gvfs                     (для монтирования и горячего подключения устройств)
# Optional:    python3-gi-docgen        (для документации)

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
# тесты проводятся в графическом окружении
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME file manager)
#
# The Nautilus package contains the GNOME file manager
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
