#! /bin/bash

PRGNAME="gtk-vnc"

### Gtk VNC (VNC viewer widget for GTK)
# Графический модуль для интеграции клиента удаленного управления VNC в любые
# программы на базе GTK. Он позволяет выводить экран другого компьютера прямо
# внутрь окна вашего приложения.

# Required:    gnutls
#              gtk+3
#              libgcrypt
# Recommended: glib
#              vala
#              pulseaudio
# Optional:    cyrus-sasl
#              python3-gi-docgen    (для документации)

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VNC viewer widget for GTK)
#
# The Gtk VNC package contains a VNC viewer widget for GTK+. It is built using
# coroutines allowing it to be completely asynchronous while remaining single
# threaded. It provides a core C library, and bindings for Python (PyGTK).
#
# Home page: https://wiki.gnome.org/Projects/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
