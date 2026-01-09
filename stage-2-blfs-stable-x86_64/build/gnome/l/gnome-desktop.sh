#! /bin/bash

PRGNAME="gnome-desktop"

### GNOME Desktop (libgnome-desktop library)
# Библиотеки, предоставляющие общий API для приложений рабочего стола GNOME

# Required:    gsettings-desktop-schemas
#              gtk+3
#              gtk4
#              iso-codes
#              itstool
#              libseccomp
#              libxml2
#              xkeyboard-config
# Recommended: bubblewrap           (для thumbnailers в nautilus)
#              glib
# Optional:    gtk-doc

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
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"
rm -rf "${TMP_DIR}/usr/share/help"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (libgnome-desktop library)
#
# The GNOME Desktop package contains a library that provides an API shared by
# several applications on the GNOME Desktop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
