#! /bin/bash

PRGNAME="xdg-desktop-portal-gtk"

### xdg-desktop-portal-gtk (gtk sandboxing desktop APIs)
# Реализация портала рабочего стола XDG для среды рабочего стола на основе GTK.
# Порталы являются фреймворком, который позволяет приложениям, работающим в
# "песочнице" (например, Flatpak), безопасно взаимодействовать с ресурсами
# хост-системы, такими как файловая система, камера, или использовать системные
# диалоговые окна (например, для открытия или сохранения файлов)

# Required:    gnome-desktop
#              gtk+3
#              xdg-desktop-portal
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

# удалим файлы systemd, которые в нашей системе бесполезны
rm -rvf "${TMP_DIR}/usr/lib/systemd"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (gtk sandboxing desktop APIs)
#
# xdg-desktop-portal-gtk is a backend for xdg-desktop-portal, that is using GTK
# and various pieces of GNOME infrastructure
#
# Home page: https://github.com/flatpak/${PRGNAME}/
# Download:  https://github.com/flatpak/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
