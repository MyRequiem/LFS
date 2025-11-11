#! /bin/bash

PRGNAME="xwayland"

### Xwayland (X Clients under Wayland)
# xorg-сервер, работающий поверх сервера Wayland и позволяющий запускать
# X-клиентов внутри сеанса Wayland

# Required:    libxcvt
#              pixman
#              wayland-protocols
#              xorg-applications    (runtime + утилита bdftopcf)
#              xorg-fonts           (пакет font-util)
# Recommended: libepoxy
#              libtirpc
#              mesa
# Optional:    git                  (для тестов)
#              libei
#              libgcrypt
#              nettle
#              xmlto
#              rendercheck          (для тестов) https://gitlab.freedesktop.org/xorg/test/rendercheck
#              weston               (для тестов) https://wayland.pages.freedesktop.org/weston/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# не устанавливаем man-страницу для xorg-server
sed -i '/install_man/,$d' meson.build || exit 1

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -D xkb_output_dir=/var/lib/xkb || exit 1

ninja || exit 1

### тесты
# mkdir tools
# pushd tools || exit 1
#
# git clone https://gitlab.freedesktop.org/mesa/piglit.git --depth 1 || exit 1
# cat > piglit/piglit.conf << EOF
# [xts]
# path=$(pwd)/xts
# EOF
#
# git clone https://gitlab.freedesktop.org/xorg/test/xts --depth 1 || exit 1
#
# export DISPLAY=:22           || exit 1
# ../hw/vfb/Xvfb $DISPLAY      || exit 1
# VFB_PID=$!                   || exit 1
# cd xts                       || exit 1
# CFLAGS=-fcommon ./autogen.sh || exit 1
# make                         || exit 1
# kill $VFB_PID                || exit 1
# unset DISPLAY VFB_PID        || exit 1
# popd                         || exit 1
# XTEST_DIR=$(pwd)/tools/xts PIGLIT_DIR=$(pwd)/tools/piglit ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X Clients under Wayland)
#
# Wayland is a complete window system in itself, but even so, if we're
# migrating away from X, it makes sense to have a good backwards compatibility
# story. With a few changes, the Xorg server can be modified to use Wayland
# input devices for input and forward either the root window or individual
# top-level windows as wayland surfaces. The server still runs the same 2D
# driver with the same acceleration code as it does when it runs natively. The
# main difference is that Wayland handles presentation of the windows instead
# of KMS
#
# Home page: https://www.x.org/pub/individual/xserver/
# Download:  https://www.x.org/pub/individual/xserver/xwayland-24.1.8.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
