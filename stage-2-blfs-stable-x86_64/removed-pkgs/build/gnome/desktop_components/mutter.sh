#! /bin/bash

PRGNAME="mutter"

### Mutter (GNOME Display Server and Window Manager)
# Оконный менеджер и композитный сервер, который используется по умолчанию в
# рабочей среде GNOME. Управляет окнами приложений, обрабатывает графические
# эффекты и обеспечивает плавную работу пользовательского интерфейса. Mutter
# может работать как с классическим дисплейным сервером X11, так и с
# современным Wayland

# Required:    python3-docutils
#              gnome-settings-daemon
#              graphene
#              libei
#              libxcvt
#              libxkbcommon
#              pipewire
# Recommended: desktop-file-utils
#              glib
#              libdisplay-info
#              startup-notification
#              --- для Wayland compositor ---
#              libinput
#              wayland
#              wayland-protocols
#              xwayland
#              --- runtime ---
#              blocaled
# Optional:    --- для тестов ---
#              python3-dbusmock
#              xorg-server
#              bash-completion                      (https://github.com/scop/bash-completion/)
#              sysprof                              (https://wiki.gnome.org/Apps/Sysprof)
#              xvfb-run                             (https://anduin.linuxfromscratch.org/BLFS/mutter/xvfb-run)
#              zenity                               (https://gitlab.gnome.org/GNOME/zenity)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему с тестами, которые в противном случае потребовали бы сборки
# данного пакета вместе с отладочной информацией
sed "/tests_c_args =/s/$/ + ['-U', 'G_DISABLE_ASSERT']/" -i \
    src/tests/meson.build || exit 1
sed "/c_args:/a '-U', 'G_DISABLE_ASSERT'," -i \
    src/tests/cogl/unit/meson.build || exit 1

mkdir build
cd build || exit 1

# для сборки с bash_completion
#    -D bash_completion=true
# требуется модуль python3-argcomplete, который не входит в состав LFS-BLFS
meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D tests=disabled        \
    -D profiler=false        \
    -D bash_completion=false \
    .. || exit 1

ninja || exit 1
# тесты проводятся в графическом окружении
# meson configure -D tests=enabled || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Display Server and Window Manager)
#
# Mutter is the window manager for GNOME. It is not invoked directly, but from
# GNOME Session (on a machine with a hardware accelerated video driver)
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
