#! /bin/bash

PRGNAME="libsecret"

### libsecret (library to access the Secret Service API)
# Библиотека на основе GObject для доступа к Secret Service API

# Required:    glib
# Recommended: gobject-introspection
#              libgcrypt
#              vala
# Optional:    gtk-doc            (для сборки документации)
#              docbook-xml
#              docbook-xsl
#              libxslt            (для сборки man-страниц)
#              valgrind           (для тестов)
#              python3-dbus       (для тестов)
#              gjs                (для тестов)
#              python3-pygobject3 (для тестов)
#              gnome-keyring

### NOTE:
# Любой пакет, требующий libsecret, ожидает, что GNOME Keyring будет
# присутствовать во время выполнения

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="false"
MANPAGES="false"
GCRYPT="false"
VALA="false"
INTROSPECTION="false"

# command -v gtkdoc-check  &>/dev/null && GTK_DOC="true"
command -v xslt-config   &>/dev/null && MANPAGES="true"
command -v dumpsexp      &>/dev/null && GCRYPT="true"
command -v vala          &>/dev/null && VALA="true"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="true"

mkdir bld
cd bld || exit 1

meson                                  \
    --prefix=/usr                      \
    -Dgtk_doc="${GTK_DOC}"             \
    -Dmanpage="${MANPAGES}"            \
    -Dgcrypt="${GCRYPT}"               \
    -Dvapi="${VALA}"                   \
    -Dintrospection="${INTROSPECTION}" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

# тестирование нужно проводить только после установки пакета в систему и при
# запущенном сеансе Xorg с помощью dbus-launch
# ninja test

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library to access the Secret Service API)
#
# The libsecret package contains a GObject based library for accessing the
# Secret Service API
#
# Home page: https://wiki.gnome.org/Projects/Libsecret
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
