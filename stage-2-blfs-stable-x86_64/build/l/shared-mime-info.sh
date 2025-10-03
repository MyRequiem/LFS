#! /bin/bash

PRGNAME="shared-mime-info"

### shared-mime-info (Freedesktop common MIME database)
# База данных MIME

# Required:    glib
#              libxml2
# Recommended: no
# Optional:    xmlto

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если будем запускать тесты
# tar -xf "${SOURCES}/xdgmime.tar.xz" || exit 1
# make -C xdgmime

mkdir build
cd build || exit 1

# указываем системе сборки запускать update-mime-database во время установки
#    -Dupdate-mimedb=true
meson setup               \
    --prefix=/usr         \
    --buildtype=release   \
    -D update-mimedb=true \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Freedesktop common MIME database)
#
# This package contains:
# The freedesktop.org shared MIME database spec.
# The merged GNOME and KDE databases, in the new format.
# The update-mime-database command, used to install new MIME data.
#
# Home page: https://freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/xdg/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
