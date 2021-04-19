#! /bin/bash

PRGNAME="shared-mime-info"

### shared-mime-info (Freedesktop common MIME database)
# База данных MIME

# Required:    glib
#              itstool
#              libxml2
#              xmlto
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# указываем системе сборки запускать update-mime-database во время установки
#    -Dupdate-mimedb=true
meson                    \
    --prefix=/usr        \
    -Dupdate-mimedb=true \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
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
# Download:  https://gitlab.freedesktop.org/xdg/${PRGNAME}/uploads/0ee50652091363ab0d17e335e5e74fbe/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
