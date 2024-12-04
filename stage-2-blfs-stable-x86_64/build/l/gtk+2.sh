#! /bin/bash

PRGNAME="gtk+2"
ARCH_NAME="gtk+"

### GTK+2 (multi-platform GUI toolkit)
# GTK (GIMP ToolKit) - кроссплатформенная библиотека элементов интерфейса
# (фреймворк). Наряду с библиотекой Qt является одной из наиболее популярных на
# сегодняшний день библиотек для X

# Required:    at-spi2-core
#              gdk-pixbuf
#              pango
# Recommended: hicolor-icon-theme
# Optional:    cups
#              docbook-utils
#              gnome-themes-extra (для создания adwaita и highcontrast icon themes)
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если пакет 'docbook-utils' установлен, то gtk+2 попытается использовать его
# для восстановления части своей HTML-документации. При этом из-за ошибок в
# некоторых файлах Makefile, возникает ошибка сборки. Исправим эти Makefile'ы
sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
    -i docs/{faq,tutorial}/Makefile.in || exit 1

GTK_DOC="no"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="yes"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --enable-gtk-doc="${GTK_DOC}" || exit 1

make || exit 1
# make -k check
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "xno" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

IM_MULTIPRESS_CONF="/etc/gtk-2.0/im-multipress.conf"
if [ -f "${IM_MULTIPRESS_CONF}" ]; then
    mv "${IM_MULTIPRESS_CONF}" "${IM_MULTIPRESS_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${IM_MULTIPRESS_CONF}"

# создаем файл /usr/lib/gtk-2.x/2.xx.x/immodules.cache
gtk-query-immodules-2.0 --update-cache

# копируем созданный immodules.cache в ${TMP_DIR}
IMMODULES_CACHE="$(find /usr/lib/gtk-2* -type f -name immodules\.cache)"
cp "${IMMODULES_CACHE}" "${TMP_DIR}${IMMODULES_CACHE}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (multi-platform GUI toolkit)
#
# This is GTK+, a multi-platform toolkit for creating graphical user interfaces
# for applications. Offering a complete set of widgets, GTK+ is suitable for
# projects ranging from small one-off projects to complete application suites.
#
# Home page: https://www.gtk.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
