#! /bin/bash

PRGNAME="libcroco"

### libcroco (CSS2 parsing and manipulation library)
# Библиотека для анализа и манипулирования CSS2

# http://www.linuxfromscratch.org/blfs/view/stable/general/libcroco.html

# Home page: https://github.com/GNOME/libcroco
# Download:  http://ftp.gnome.org/pub/gnome/sources/libcroco/0.6/libcroco-0.6.13.tar.xz

# Required: glib
#           libxml2
# Optional: gtk-doc (для создания API документации, см. опции конфигурации ниже)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    --disable-static || exit 1

make || exit 1
# make -k test
make install
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (CSS2 parsing and manipulation library)
#
# Libcroco is a standalone CSS2 parsing and manipulation library. The parser
# provides a low level event driven SAC like API and a CSS object model like
# API. Libcroco provides a CSS2 selection engine and an experimental XML/CSS
# rendering engine.
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
