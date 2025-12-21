#! /bin/bash

PRGNAME="tinysparql"

### TinySPARQL (RDF triple store with a SPARQL 1.1 interface)
# Легковесная реализация хранилища RDF-триплетов (объектов) с интерфейсом
# SPARQL 1.1. Это библиотека, которую можно использовать для создания локальных
# баз данных, подключения к удаленным конечным точкам для федеративных запросов
# или создания собственных публичных конечных точек. TinySPARQL является базой
# данных для такого приложения, как LocalSearch, и используется другими
# приложениями для хранения, запросов и публикации структурированных данных с
# помощью SPARQL

# Required:    json-glib
#              vala
# Recommended: glib
#              icu
#              libsoup3
#              localsearch          (runtime)
#              python3-pygobject3
#              sqlite
# Optional:    python3-asciidoc     (для генерации man-страниц)
#              avahi
#              graphviz
#              bash-completion      (https://github.com/scop/bash-completion/)
#              libstemmer           (https://snowballstem.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим место для установки документации
sed -e "s/'generate'/&, '--no-namespace-dir'/"         \
    -e "/--output-dir/s/@OUTPUT@/&\/tinysparql-3.9.2/" \
    -i docs/reference/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup                        \
    --prefix=/usr                  \
    --buildtype=release            \
    -D man=false                   \
    -D systemd_user_services=false \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# тесты проводят после установки пакета в систему
# meson configure -D debug=true && LC_ALL=C.UTF-8 ninja test

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RDF triple store with a SPARQL 1.1 interface)
#
# Tinysparql is a low-footprint RDF triple store with a SPARQL 1.1 interface
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
