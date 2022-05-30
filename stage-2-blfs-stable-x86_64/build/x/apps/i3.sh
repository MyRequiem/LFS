#! /bin/bash

PRGNAME="i3"

### i3 (an improved dynamic tiling window manager)
# Тайловый оконный менеджер.

# Required:    libxcb
#              xcb-util
#              xcb-util-cursor
#              xcb-util-wm
#              xcb-util-keysyms
#              xcb-util-xrm
#              libev
#              libxkbcommon
#              libyajl
#              asciidoc
#              xmlto
#              docbook-xml
#              pcre
#              startup-notification
#              pango
#              cairo
#              perl-pod-simple
#              perl-common-sense
#              perl-canary-stability
#              perl-types-serialiser
#              perl-json-xs
#              perl-anyevent
#              perl-anyevent-i3
#              dmenu
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/txt"

mkdir build
cd build || exit 1

meson                       \
    --prefix=/usr           \
    -Dmans=true             \
    -Ddocs=true             \
    -Ddocdir="${DOCS}/html" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# документация
cd ../ || exit 1
cp -a DEPENDS LICENSE RELEASE-NOTES-* "${TMP_DIR}${DOCS}"
find docs/ -type f ! \(     \
        -name "*.conf" -o   \
        -name "*.asy"  -o   \
        -name "*.png"  -o   \
        -name "*.html" -o   \
        -name "*.css"  -o   \
        -name "*.svg"  -o   \
        -name "*.dia"  -o   \
        -name "i3-pod2html" \
    \) -exec cp {} "${TMP_DIR}${DOCS}/txt" \;

chown -R root:root "${TMP_DIR}${DOCS}"/*

# uxterm - терминал по умолчанию
sed -i 's/i3-sensible-terminal/uxterm/' "${TMP_DIR}/etc/i3/config"

CONFIG="/etc/i3/config"
if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

CONFIG_KEYCODES="/etc/i3/config.keycodes"
if [ -f "${CONFIG_KEYCODES}" ]; then
    mv "${CONFIG_KEYCODES}" "${CONFIG_KEYCODES}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CONFIG}"
config_file_processing "${CONFIG_KEYCODES}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an improved dynamic tiling window manager)
#
# i3 is a tiling window manager, completely written from scratch.
#
# i3 was created because wmii, our favorite window manager at the time, didn't
# provide some features we wanted (multi-monitor done right, for example), had
# some bugs, didn't progress since quite some time and wasn't easy to hack at
# all (source code comments/documentation completely lacking). Still, we think
# the wmii developers and contributors did a great job.
#
# Home page: https://www.${PRGNAME}wm.org
# Download:  https://${PRGNAME}wm.org/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
