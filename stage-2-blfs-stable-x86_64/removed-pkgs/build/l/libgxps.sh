#! /bin/bash

PRGNAME="libgxps"

### Libgxps (library for handling and rendering XPS documents)
# Библиотека на основе GObject, предоставляющая интерфейс для обработки и
# рендеринга XPS-документов.

# Required:    gtk+3
#              lcms2
#              libarchive
#              libjpeg-turbo
#              libtiff
#              libxslt
# Recommended: no
# Optional:    git
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                       \
    --prefix=/usr                 \
    --buildtype=release           \
    -D enable-test=false          \
    -D enable-man=true            \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

chmod 644 "${TMP_DIR}/usr/share/man/man1/"*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for handling and rendering XPS documents)
#
# libgxps is a GObject based library provides an interface for handling and
# rendering XPS documents.
#
# Home page: https://wiki.gnome.org/Projects/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
