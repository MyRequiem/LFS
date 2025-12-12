#! /bin/bash

PRGNAME="libportal"

### libportal (Flatpak portal library)
# Библиотека упрощающая взаимодействие с порталами D-Bus. Предоставляет
# разработчикам удобный асинхронный интерфейс в стиле GIO, скрывая сложность
# прямого использования D-Bus, что позволяет приложениям безопасно и эффективно
# получать доступ к системным функциям, таким как открытие файлов, доступ к
# камере или местоположению и т.д.

# Required:    glib
# Recommended: gtk+3
#              gtk4
#              xdg-desktop-portal           (runtime)
#              --- для GNOME ---
#              xdg-desktop-portal-gtk       (runtime)
#              xdg-desktop-portal-gnome     (runtime)
#              --- для LXQt ---
#              xdg-desktop-portal-lxqt      (runtime)
# Optional:    python3-gi-docgen
#              python3-dbusmock
#              python3-pytest
#              qt6
#              vala

###
# WARNING
###
# Перед переустановкой пакета его нужно сначала удалить из системы
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --version -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-qt6.9_fixes-1.patch" || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D vapi=false       \
    -D docs=false       \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Flatpak portal library)
#
# The libportal package provides a library that contains GIO-style async APIs
# for most Flatpak portals
#
# Home page: https://github.com/flatpak/${PRGNAME}/
# Download:  https://github.com/flatpak/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
