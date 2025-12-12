#! /bin/bash

PRGNAME="gjs"

### Gjs (set of Javascript bindings for GObjects)
# Набор Javascript привязок для GNOME

# Required:    cairo
#              dbus
#              glib
#              spidermonkey-js-engine
# Recommended: gtk+3
#              gtk4
# Optional:    valgrind                 (для тестов)
#              dtrace                   (http://dtrace.org/blogs/about/)
#              lcov                     (https://ltp.sourceforge.net/coverage/lcov.php)
#              sysprof                  (https://wiki.gnome.org/Apps/Sysprof)
#              systemtap                (https://sourceware.org/systemtap/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# разрешим сборку SpiderMonkey-140
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-spidermonkey_140-1.patch" || exit 1

mkdir gjs-build
cd gjs-build || exit 1

meson setup                \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    .. || exit 1

ninja || exit 1
# тесты проводятся в графической среде
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (set of Javascript bindings for GObjects)
#
# Gjs is a set of Javascript bindings for GNOME
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
