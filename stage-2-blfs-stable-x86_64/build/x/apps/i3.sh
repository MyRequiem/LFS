#! /bin/bash

PRGNAME="i3"

### i3 (an improved dynamic tiling window manager)
# Тайловый оконный менеджер.

# Required:    xcb-util
#              xcb-util-xrm
#              xcb-util-cursor
#              xcb-util-wm
#              xcb-util-keysyms
#              libev
#              libxkbcommon
#              libyajl
#              python3-asciidoc
#              xmlto
#              docbook-xml
#              pcre2
#              startup-notification
#              pango
#              cairo
#              perl-anyevent-i3
#              dmenu
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

DOSC="false"

meson                                               \
    --prefix /usr                                   \
    --sysconfdir /etc                               \
    -Dmans=true                                     \
    -Ddocs="${DOSC}"                                \
    -Ddocdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

[ "x${DOSC}" == "xfalse" ] && rm -rf "${TMP_DIR}/usr/share/doc"

# заменим терминал по умолчанию i3-sensible-terminal на xterm
sed -i 's/i3-sensible-terminal/xterm/' "${TMP_DIR}/etc/i3/config" || exit 1

CONFIG="/etc/i3/config"
if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CONFIG}"

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
