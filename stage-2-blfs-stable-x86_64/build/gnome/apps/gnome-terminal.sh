#! /bin/bash

PRGNAME="gnome-terminal"

### GNOME Terminal (GNOME Terminal)
# Стандартный эмулятор терминала для среды рабочего стола GNOME

# Required:    dconf
#              gsettings-desktop-schemas
#              itstool
#              libhandy
#              pcre2
#              vte3
# Recommended: gnome-shell
#              nautilus
# Optional:    appstream-glib
#              desktop-file-utils

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим некоторые устаревшие записи в файлах схем
sed -i -r 's:"(/system):"/org/gnome\1:g' src/external.gschema.xml || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -fv "${TMP_DIR}/usr/lib/systemd/user/gnome-terminal-server.service"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Terminal)
#
# The GNOME Terminal package contains the terminal emulator for GNOME Desktop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://gitlab.gnome.org/GNOME/${PRGNAME}/-/archive/3.56.0/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
