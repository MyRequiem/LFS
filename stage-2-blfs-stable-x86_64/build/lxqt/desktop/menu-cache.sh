#! /bin/bash

PRGNAME="menu-cache"

### menu-cache (creating and utilizing caches application menus)
# Специальный системный демон, который кэширует структуру меню приложений для
# ускорения его работы. Он избавляет систему от необходимости заново читать все
# ярлыки при каждом открытии меню.

# Required:    libfm-extra
# Recommended: no
# Optional:    xdg-utils

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# Жестко требует наличие пакета gtk-doc (утилиту gtkdocize, m4-макросы и т.д.),
# поэтому соберем gtk-doc в дереве исходников menu-cache без установки в
# систему, а потом ХАКНЕМ сам menu-cache.
###

tar xvf "${SOURCES}/gtk-doc"*.tar.?z* || exit 1
cd gtk-doc-* || exit 1

mkdir -p build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D tests=false || exit 1

ninja || exit 1

# переходим в корень исходников menu-cache
cd ../../ || exit 1

cp gtk-doc-*/build/buildsystems/autotools/gtkdocize . || exit 1

mkdir -p fake/aclocal
mkdir -p fake/gtk-doc/data

cp gtk-doc-*/build/buildsystems/autotools/gtk-doc.m4 fake/aclocal/  || exit 1
cp gtk-doc-*/buildsystems/autotools/gtk-doc.make fake/gtk-doc/data/ || exit 1

rm -rf gtk-doc-*

# ХАК: Переписываем внутренние переменные путей внутри скрипта gtkdocize.
# Заставим его считать, что системный префикс - это наша локальная директория
# fake
sed -e "s|^prefix=.*|prefix=\"$(pwd)/fake\"|g"   \
    -e "s|^datadir=.*|datadir=\"$(pwd)/fake\"|g" \
    -i gtkdocize || exit 1

PATH=".:${PATH}"              \
ACLOCAL_PATH="./fake/aclocal" \
sh autogen.sh || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

SDIRS="libmenu-cache menu-cache-gen menu-cache-daemon"
make SUBDIRS="${SDIRS}" || exit 1
make SUBDIRS="${SDIRS}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (creating and utilizing caches application menus)
#
# The Menu Cache package contains a library for creating and utilizing caches
# to speed up the manipulation for freedesktop.org defined application menus
#
# Home page: https://github.com/lxde/${PRGNAME}/
# Download:  https://github.com/lxde/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
