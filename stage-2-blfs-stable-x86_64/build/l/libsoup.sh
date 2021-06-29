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
#              sysprof
#              vala
# Optional:    apache-httpd     (для тестов)
#              brotli
#              curl             (для тестов)
#              mit-kerberos-v5  (для тестов)
#              gtk-doc
#              php              (собранный с поддержкой xmlrpc-epi для тестов)
#              samba            (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GSSAPI="disabled"
VALA_API="disabled"
INTROSPECTION="disabled"
GTK_DOC="false"
TESTS="false"

command -v krb5-config   &>/dev/null && GSSAPI="enabled"
command -v vala          &>/dev/null && VALA_API="enabled"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="enabled"
# command -v gtkdoc-check  &>/dev/null && GTK_DOC="true"

# исправим проблему в комплекте тестов, вызванную glib-networking
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-testsuite_fix-1.patch" || exit 1

mkdir build
cd build || exit 1

meson                                  \
    --prefix=/usr                      \
    -Dgssapi="${GSSAPI}"               \
    -Dtests="${TESTS}"                 \
    -Dvapi="${VALA_API}"               \
    -Dgtk_doc="${GTK_DOC}"             \
    -Dintrospection="${INTROSPECTION}" \
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
