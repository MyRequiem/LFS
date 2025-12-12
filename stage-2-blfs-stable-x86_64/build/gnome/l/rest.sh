#! /bin/bash

PRGNAME="rest"

### rest (RESTful Library)
# Библиотека для облегчения доступа к RESTful веб-сервисам. Включает в себя
# удобные оболочки для libsoup и libxml, упрощающие удаленное использование
# RESTful API

# Required:    json-glib
#              libsoup3
#              make-ca
# Recommended: glib
# Optional:    python3-gi-docgen
#              libadwaita           (для сборки demo)
#              gtksourceview5       (для сборки demo)
#              vala

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
    -D vapi=true        \
    -D gtk_doc=false    \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RESTful Library)
#
# The rest package contains a library that was designed to make it easier to
# access web services that claim to be "RESTful". It includes convenience
# wrappers for libsoup and libxml to make remote usage of the RESTful API
# easier
#
# Home page: https://download.gnome.org/sources/${PRGNAME}/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
