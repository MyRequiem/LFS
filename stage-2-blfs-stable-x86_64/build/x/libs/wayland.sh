#! /bin/bash

PRGNAME="wayland"

### Wayland (Wayland display server)
# Современный протокол для управления графическим интерфейсом в Linux, который
# пришел на смену старому X11. Отвечает за то, как окна программ отрисовываются
# на экране и как система обрабатывает пользовательские действия (клики мышью,
# изменение размера/перетаскивание окон и т.д), делая это более плавно и
# безопасно.

# Required:    libxml2
# Recommended: no
# Optional:    --- для документации ---
#              doxygen
#              graphviz
#              xmlto
#              --- для генерации man-страниц ---
#              docbook-xml
#              docbook-xsl
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    -D documentation=false || exit 1

ninja || exit 1
# env -u XDG_RUNTIME_DIR ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Wayland display server)
#
# Wayland is protocol for a compositor to talk to its clients as well as a
# library implementation of the protocol. The compositor can be a standalone
# display server running on Linux kernel modesetting and evdev input devices,
# an X application, or a wayland client itself. The clients can be traditional
# applications, X servers (rootless or fullscreen) or other display servers.
#
# Home page: https://${PRGNAME}.freedesktop.org/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/releases/${VERSION}/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
