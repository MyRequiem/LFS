#! /bin/bash

PRGNAME="zenity"

### Zenity (display gtk dialog boxes from cli)
# Утилита, позволяющая простым скриптам открывать красивые графические окна:
# сообщения, запросы файлов, календари, формы ввода, индикаторы прогресса,
# делая работу в терминале нагляднее.

# Required:    gtk4
#              libadwaita
#              help2man      (для генерации man-страниц)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses,applications,icons}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (display gtk dialog boxes from cli)
#
# Zenity is a tool that allows you to display Gtk+ dialog boxes from the
# command line and through shell scripts. It is similar to gdialog, but is
# intended to be saner.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://github.com/GNOME/${PRGNAME}/archive/refs/tags/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
