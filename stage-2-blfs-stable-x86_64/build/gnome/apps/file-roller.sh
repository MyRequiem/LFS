#! /bin/bash

PRGNAME="file-roller"

### File Roller (an archive manager for GNOME)
# Графическая программа-архиватор для среды рабочего стола GNOME, которая
# предоставляет удобный интерфейс для работы с архивами - создание, извлечение,
# просмотр содержимого и изменение файлов. Она работает как оболочка для
# командных утилит (например, tar, zip, gzip) и поддерживает множество
# форматов, упрощая управление архивами без необходимости использования
# командной строки.

# Required:    gtk4
#              itstool
# Recommended: cpio
#              desktop-file-utils
#              json-glib
#              libarchive
#              libadwaita
#              libportal
#              nautilus
#  Optional:   python3-gi-docgen
#              --- runtime ---
#              unrar
#              zip

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup              \
    --prefix=/usr        \
    --buildtype=release  \
    -D packagekit=false  \
    -D api_docs=disabled \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

chmod -v 0755 "${TMP_DIR}/usr/libexec/file-roller/isoinfo.sh"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш схем GLib
glib-compile-schemas /usr/share/glib-2.0/schemas
# обновим кэш иконок и .desktop файлов
gtk-update-icon-cache -qtf /usr/share/icons/hicolor
update-desktop-database -q

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an archive manager for GNOME)
#
# File Roller is an archive manager for GNOME with support for tar, bzip2,
# bzip3, gzip, zip, jar, compress, lzop, zstd, dmg, and many other archive
# formats
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
