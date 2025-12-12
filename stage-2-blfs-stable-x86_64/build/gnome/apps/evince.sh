#! /bin/bash

PRGNAME="evince"

### Evince (a simple gtk-based document viewer)
# Популярный, простой и быстрый просмотрщик документов для среды GNOME (и не
# только), который позволяет открывать и читать файлы в различных форматах,
# таких как PDF, PostScript (PS, EPS), DjVu, TIFF, DVI и даже комиксы (CBR,
# CBZ), а также искать, печатать и аннотировать их. Его цель - объединить
# функции множества разрозненных программ в одном удобном приложении,
# предоставляя минималистичный, но функциональный интерфейс.

# Required:    adwaita-icon-theme
#              gsettings-desktop-schemas
#              gtk+3
#              itstool
#              libhandy
#              libxml2
#              openjpeg
# Recommended: gnome-keyring
#              glib
#              libarchive
#              libsecret
#              poppler
# Optional:    cups
#              gnome-desktop
#              gspell
#              gst-plugins-base
#              python3-gi-docgen
#              libgxps
#              libtiff
#              texlive или install-tl-unx
#              djvulibre                    (https://djvu.sourceforge.net/)
#              libspectre                   (https://www.freedesktop.org/wiki/Software/libspectre/)
#              synctex                      (https://github.com/jlaurens/synctex)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# убедимся, что meson может найти заголовки libkpathsea из texlive, если он
# установлен (это не влияет на системы, где texlive не установлен)
CPPFLAGS+=" -I/opt/texlive/2025/include -DNO_DEBUG" \
meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D gtk_doc=false         \
    --wrap-mode=nodownload   \
    -D systemduserunitdir=no \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш схем GLib
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a simple gtk-based document viewer)
#
# Evince is a document viewer for multiple document formats. It supports PDF,
# Postscript, DjVu, TIFF and DVI. It is useful for viewing documents of various
# types using one simple application instead of the multiple document viewers
# that once existed on the GNOME Desktop
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
