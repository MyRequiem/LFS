#! /bin/bash

PRGNAME="gtk-doc"

### GTK-Doc (a code documenter)
# Документатор кода, используемый для извлечения специально отформатированных
# комментариев из кода и создания API документации.

# Required:    docbook-xml
#              docbook-xsl
#              glib
#              itstool
#              libxslt
#              python3-pygments
# Recommended: no
# Optional:    fop или dblatex          (для поддержки xml, pdf) https://sourceforge.net/projects/dblatex/
#              which
#              python3-lxml
#              python3-parameterized    (https://pypi.org/project/parameterized/)
#              yelp-tools               (https://download.gnome.org/sources/yelp-tools/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a code documenter)
#
# The GTK-Doc package contains a code documenter. This is useful for extracting
# specially formatted comments from the code to create API documentation. This
# package is optional; if it is not installed, packages will not build the
# documentation. This does not mean that you will not have any documentation.
# If GTK-Doc is not available, the install process will copy any pre-built
# documentation to your system.
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
