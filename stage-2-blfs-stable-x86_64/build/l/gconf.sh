#! /bin/bash

PRGNAME="gconf"
ARCH_NAME="GConf"

### GConf (GNOME configuration library)
# Система базы данных конфигурации, используемая многими GNOME приложениями и
# утилиты для управления базой данных GConf

# Required:    dbus-glib
#              libxml2
# Recommended: gobject-introspection
#              gtk+3
#              polkit
# Optional:    openldap

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# ORBit2 это устаревший пакет, не используем его
#    --disable-orbit
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-orbit   \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

# ссылка в /etc/gconf/ на директорию:
#    gconf.xml.system -> gconf.xml.defaults
ln -sf gconf.xml.defaults "${TMP_DIR}/etc/gconf/gconf.xml.system"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME configuration library)
#
# GConf is a configuration database system designed for the GNOME project and
# applications based on GTK+. It is conceptually similar to the Windows
# registry.
#
# Home page: https://www.gnome.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
