#! /bin/bash

PRGNAME="libxml2"

### libxml2 (XML parser library)
# Библиотека для чтения и записи XML-файлов, которые широко используются для
# хранения настроек и обмена данными.

# Required:    no
# Recommended: icu      (для лучшей поддержки UNICODE)
# Optional:    doxygen
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим ненужный вызов git в meson.build
sed -i "/'git'/,+3d" meson.build || exit 1

ICU="disabled"
command -v icu-config &>/dev/null && ICU="enabled"

mkdir build
cd build || exit 1

# включает поддержку Readline при запуске xmlcatalog или xmllint в консоли
#    -D history=enabled
# python bindings устарели из-за недостатков конструкции API и будут удалены в
# libxml2-2.16, а так же их сборка в версии 2.15.2 требует жесткую зависимость
# doxygen
#    -D python=disabled
meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D history=enabled  \
    -D python=disabled  \
    -D docs=disabled    \
    -D icu="${ICU}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# пакеты, которые зависят он libxml2 будут связываться только с общими
# библиотеками, а не со статическими
sed "s/--static/--shared/" -i "${TMP_DIR}/usr/bin/xml2-config"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML parser library)
#
# Libxml2 is the XML C parser library and toolkit. XML itself is a metalanguage
# to design markup languages -- i.e. a text language where structures are added
# to the content using extra "markup" information enclosed between angle
# brackets. HTML is the most well-known markup language. Though the library is
# written in C, a variety of language bindings make it available in other
# environments.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}/-/wikis/home
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
