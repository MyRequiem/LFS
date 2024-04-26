#! /bin/bash

PRGNAME="libsoup"

### libsoup (an HTTP client/server library)
# Реализация HTTP клиент/сервер библиотеки на C, использующей GObjects и glib
# для интеграции с приложениями GTK+, а также синхронный API, подходящий для
# использования в многопоточных приложениях

# Required:    glib-networking
#              libpsl
#              libxml2
#              sqlite
# Recommended: gobject-introspection
#              vala
# Optional:    apache-httpd     (для тестов)
#              brotli
#              curl             (для тестов)
#              sysprof
#              mit-kerberos-v5  (для тестов)
#              gtk-doc
#              php              (собранный с поддержкой xmlrpc-epi для тестов)
#              samba            (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${PRGNAME}-2*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALA_API="disabled"
GSSAPI="disabled"
TESTS="false"
GTK_DOC="false"

command -v vala         &>/dev/null && VALA_API="enabled"
command -v krb5-config  &>/dev/null && GSSAPI="enabled"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"

mkdir build
cd build || exit 1

meson                      \
    --prefix=/usr          \
    --buildtype=release    \
    -Dvapi="${VALA_API}"   \
    -Dgssapi="${GSSAPI}"   \
    -Dsysprof=disabled     \
    -Dtests="${TESTS}"     \
    -Dgtk_doc="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1

# для тестов устанавливаем переменнут TESTS выше в 'true'
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an HTTP client/server library)
#
# Soup is an HTTP client/server library implementation in C. It uses GObjects
# and the glib main loop to integrate well with GTK+ applications, and has a
# synchronous API suitable for use in threaded applications.
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
