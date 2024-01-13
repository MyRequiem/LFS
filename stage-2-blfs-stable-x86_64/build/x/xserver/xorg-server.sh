#! /bin/bash

PRGNAME="xorg-server"

### Xorg-Server (The Xorg server, the core of the X Window System)
# Полнофункциональный X-сервер, изначально разработанный для UNIX и
# UNIX-подобных операционных систем.

# Required:    pixman
#              xorg-fonts
#              xkeyboard-config
# Recommended: elogind
#              libepoxy            (для glamor и xwayland)
#              polkit
#              wayland             (для xwayland)
#              wayland-protocols
# Optional:    acpid
#              doxygen             (для сборки документации)
#              fop                 (для сборки документации)
#              libunwind
#              nettle              (для сборки xephyr)
#              libgcrypt           (для сборки xephyr)
#              xcb-util-keysyms    (для сборки xephyr)
#              xcb-util-image      (для сборки xephyr)
#              xcb-util-renderutil (для сборки xephyr)
#              xcb-util-wm         (для сборки xephyr)
#              xmlto               (для сборки документации)
#              xorg-sgml-doctools  (для сборки документации) https://gitlab.freedesktop.org/xorg/doc/xorg-sgml-doctools

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/X11/xorg.conf.d"

FONT_DIRS="$(find /usr/share/fonts/X11/ -maxdepth 1 -type d)"
DEFAULTFONTPATH=""
for FONTDIR in ${FONT_DIRS}; do
    [[ "${FONTDIR}" != "/usr/share/fonts/X11/" ]] &&
        DEFAULTFONTPATH="${FONTDIR},${DEFAULTFONTPATH}"
done

DEFAULTFONTPATH="$(echo "${DEFAULTFONTPATH}" | rev | cut -d , -f 2- | rev)"

GLAMOR="--disable-glamor"
[ -x /usr/lib/libepoxy.so ] && GLAMOR="--enable-glamor"

# создаем модуль Glamour DIX (Device Independent X), который используется R600
# или более поздними наборами микросхем radeon, драйвером настройки режима
# оборудования, использующего KMS, который предлагает ускорение и (опционально)
# драйвер Intel
#    --enable-glamor
# создаем оболочку suid-root для поддержки устаревших драйверов в системах
# xserver без рута
#    --enable-suid-wrapper
# отключаем интеграцию elogind, позволяя серверу Xorg работать без настроенного
# модуля PAM
#    --disable-systemd-logind
#
# shellcheck disable=SC2086
./configure                                       \
    ${XORG_CONFIG}                                \
    --enable-xorg                                 \
    --disable-ipv6                                \
    --disable-kdrive                              \
    --with-int10=x86emu                           \
    --disable-listen-tcp                          \
    "${GLAMOR}"                                   \
    --enable-linux-acpi                           \
    --disable-xquartz                             \
    --disable-devel-docs                          \
    --disable-unit-tests                          \
    --enable-xf86bigfont                          \
    --enable-suid-wrapper                         \
    --disable-systemd-logind                      \
    --with-xkb-output=/var/lib/xkb                \
    --with-default-font-path="${DEFAULTFONTPATH}" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# для тестов конфигурируем пакет без параметра '--disable-unit-tests'
# make check

make install DESTDIR="${TMP_DIR}"

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
# Download:  https://www.x.org/pub/individual/xserver/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
