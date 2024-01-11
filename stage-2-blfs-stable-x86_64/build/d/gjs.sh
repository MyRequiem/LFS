#! /bin/bash

PRGNAME="gjs"

### Gjs (set of Javascript bindings for GObjects)
# Набор Javascript привязок для GNOME

# Required:    cairo
#              dbus
#              gobject-introspection
#              mozjs
# Recommended: gtk+3     (для сборки GNOME)
# Optional:    sysprof
#              valgrind  (для тестов)
#              dtrace    (http://dtrace.org/blogs/about/)
#              gtk4      (https://wiki.gnome.org/Projects/GTK/Roadmap/GTK4)
#              lcov      (http://ltp.sourceforge.net/coverage/lcov.php)
#              systemtap (https://sourceware.org/systemtap/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir gjs-build
cd gjs-build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1

# тесты GTK и Cairo потерпят неудачу, если сеанс Xorg не будет запущен
# ninja test

DESTDIR="${TMP_DIR}" ninja install

# ссылка в /usr/bin
#   gjs -> gjs-console
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf gjs-console gjs
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (set of Javascript bindings for GObjects)
#
# Gjs is a set of Javascript bindings for GNOME
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
