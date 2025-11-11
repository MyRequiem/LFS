#! /bin/bash

PRGNAME="libsoup2"
ARCH_NAME="libsoup"

### libsoup (an HTTP client/server library)
# Реализация HTTP клиент/сервер библиотеки на C, использующей GObjects и glib
# для интеграции с приложениями GTK+, а также синхронный API, подходящий для
# использования в многопоточных приложениях

# Required:    glib-networking
#              libpsl
#              libxml2
#              sqlite
# Recommended: glib
#              vala
# Optional:    --- для тестов ---
#              apache-httpd
#              brotli
#              curl
#              mit-kerberos-v5
#              gtk-doc
#              php              (собранный с поддержкой xmlrpc-epi)
#              samba
#              sysprof          (https://wiki.gnome.org/Apps/Sysprof)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-2*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D vapi=enabled     \
    -D gssapi=disabled  \
    -D sysprof=disabled \
    -D tests=false      \
    -D gtk_doc=false    \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${ARCH_NAME} (an HTTP client/server library)
#
# Soup is an HTTP client/server library implementation in C. It uses GObjects
# and the glib main loop to integrate well with GTK+ applications, and has a
# synchronous API suitable for use in threaded applications.
#
# Home page: https://github.com/GNOME/${ARCH_NAME}
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
