#! /bin/bash

PRGNAME="libxmlb"

### libxmlb (librarywhich help create and query binary XML blobs)
# Быстрая библиотека для создания и чтения двоичных (бинарных) данных XML
# объектов. Она преобразует тяжелые XML-файлы в компактный формат, который
# программа может загрузить в память мгновенно и без затрат на обычный парсинг.

# Required:    glib
# Recommended: no
# Optional:    gtk-doc
#              libstemmer    (https://github.com/zvelo/libstemmer)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D gtkdoc=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (librarywhich help create and query binary XML blobs)
#
# The libxmlb package contains a library and a tool which help create and query
# binary XML blobs
#
# Home page: https://github.com/hughsie/${PRGNAME}/
# Download:  https://github.com/hughsie/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
