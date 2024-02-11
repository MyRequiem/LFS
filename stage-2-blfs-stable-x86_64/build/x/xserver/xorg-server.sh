#! /bin/bash

PRGNAME="xorg-server"

### Xorg-Server (The Xorg server, the core of the X Window System)
# Полнофункциональный X-сервер, изначально разработанный для UNIX и
# UNIX-подобных операционных систем.

# Required:    libxcvt
#              pixman
#              xorg-fonts
#              xkeyboard-config
# Recommended: elogind
#              libepoxy            (для glamor и xwayland)
#              libtirpc
#              polkit
#              xorg-libinput-driver
# Optional:    acpid
#              libunwind
#              --- для сборки документации ---
#              doxygen
#              fop
#              --- для сборки xephyr ---
#              nettle
#              libgcrypt
#              xcb-util-keysyms
#              xcb-util-image
#              xcb-util-renderutil
#              xcb-util-wm
#              --- для сборки документации ---
#              xmlto
#              xorg-sgml-doctools  (https://www.x.org/archive/individual/doc/)
#              --- для тестов ---
#              rendercheck         (https://gitlab.freedesktop.org/xorg/test/rendercheck)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/X11/xorg.conf.d"

mkdir build
cd build || exit 1

meson                             \
    --prefix="${XORG_PREFIX}"     \
    --localstatedir=/var          \
    -Dsuid_wrapper=true           \
    -Dxkb_output_dir=/var/lib/xkb \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Xorg server, the core of the X Window System)
#
# Xorg is a full featured X server that was originally designed for UNIX and
# UNIX-like operating systems running on Intel x86 hardware. It now runs on a
# wider range of hardware and OS platforms. This work was derived by the X.Org
# Foundation from the XFree86 Project's XFree86 4.4rc2 release. The XFree86
# release was originally derived from X386 1.2 by Thomas Roell which was
# contributed to X11R5 by Snitily Graphics Consulting Service.
#
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/xserver/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
