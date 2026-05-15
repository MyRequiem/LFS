#! /bin/bash

PRGNAME="i3"

### i3 (an improved dynamic tiling window manager)
# Популярный тайловый оконный менеджер, который автоматически располагает окна
# на экране так, чтобы они не перекрывали друг друга. Идеален для тех, кто
# предпочитает управлять системой с клавиатуры.

# Required:    libxkbcommon
#              xcb-util-cursor
#              xcb-util-image.sh
#              xcb-util-keysyms
#              xcb-util-renderutil.sh
#              xcb-util-wm
#              xcb-util-xrm
#              pcre
#              libev
#              libyajl
#              pango
#              cairo
#              startup-notification
#              perl-anyevent-i3
# Recommended: dmenu
# Optional:    --- для документации ---
#              python3-asciidoc
#              xmlto
#              docbook-xml
#              perl-pod-simple              (http://search.cpan.org/dist/Pod-Simple/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses,xsessions}

# заменим терминал по умолчанию i3-sensible-terminal на uxterm
sed -i 's/i3-sensible-terminal/uxterm/' "${TMP_DIR}/etc/i3/config" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: https://www.${PRGNAME}wm.org/
# Download:  https://${PRGNAME}wm.org/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
