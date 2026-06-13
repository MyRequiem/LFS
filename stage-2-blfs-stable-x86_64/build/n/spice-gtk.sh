#! /bin/bash

PRGNAME="spice-gtk"

### spice-gtk (spice gtk client/libraries)
# Графический компонент для создания окон просмотра удаленных рабочих столов в
# среде GTK. С его помощью разработчики делают удобные программы для управления
# виртуальными компьютерами.

# Required:    gtk+3
#              json-glib
#              spice                (https://www.spice-space.org/)
#              vala
# Recommended: polkit
#              pulseaudio
#              libjpeg-turbo
#              cyrus-sasl
#              gstreamer
#              gst-plugins-base
#              gst-plugins-good
#              gst-plugins-bad
# Optional:    libcacard            (https://www.spice-space.org/)
#              usbredir             (https://www.spice-space.org)
#              phodav               (https://wiki.gnome.org/phodav)

### INFO
# Например, открыть в окне GTK запущенную виртуальную машину:
# $ spicy --host=127.0.0.1 --port=5900 &
#
#    Проверить какой порт нужен (от root):
#    $ ss -tlnp | grep qemu
#    3:LISTEN 0 4096 127.0.0.1:5900 0.0.0.0:* users:(("qemu-system-x86",pid=31404,fd=12))

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..               \
    --prefix=/usr            \
    -D gtk=enabled           \
    -D polkit=enabled        \
    -D vapi=enabled          \
    -D introspection=enabled \
    -D libcap-ng=enabled     \
    -D usbredir=enabled      \
    -D opus=enabled          \
    -D gtk_doc=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (spice gtk client/libraries)
#
# A Gtk client and libraries for spice remote desktop servers
#
# Home page: https://www.spice-space.org
# Download:  https://www.spice-space.org/download/gtk/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
