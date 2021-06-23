#! /bin/bash

PRGNAME="gcr"

### Gcr (crypto library and ui for gnome-keyring)
# Библиотеки для отображения сертификатов и доступа к криптографическому
# интерфейсу ключей. Также предоставляет средство просмотра зашифрованных
# файлов в GNOME

# Required:    glib
#              libgcrypt
#              p11-kit
#              vala
# Recommended: gnupg
#              gobject-introspection
#              gtk+3
#              libxslt
# Optional:    gtk-doc
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
GTK3="false"

# command -v gtkdoc-check &>/dev/null && DOCS="true"
command -v gtk3-demo &>/dev/null && GTK3="true"

# исправим устаревшие записи в файлах схем
sed -i 's:"/desktop:"/org:' schema/*.xml || exit 1

mkdir gcr-build
cd gcr-build || exit 1

meson                   \
    --prefix=/usr       \
    -Dgtk="${GTK3}"     \
    -Dgtk_doc="${DOCS}" \
    .. || exit 1

ninja || exit 1

# тесты запускаются только в графической среде
ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (crypto library and ui for gnome-keyring)
#
# GCR is a library for displaying certificates and crypto UI accessing key
# stores. It also provides the viewer for crypto files on the GNOME desktop.
#
# Home page: https://www.gnome.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
