#! /bin/bash

PRGNAME="zenity"

### Zenity (display gtk dialog boxes from cli)
# Инструмент, который позволяет отображать диалоговые окна Gtk+ из командной
# строки и через сценарии оболочки.

# Required:    gtk+3
#              itstool
# Recommended: libnotify
#              libxslt
# Optional:    webkitgtk

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (display gtk dialog boxes from cli)
#
# Zenity is a tool that allows you to display Gtk+ dialog boxes from the
# command line and through shell scripts. It is similar to gdialog, but is
# intended to be saner.
#
# Home page: https://live.gnome.org/Zenity
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
