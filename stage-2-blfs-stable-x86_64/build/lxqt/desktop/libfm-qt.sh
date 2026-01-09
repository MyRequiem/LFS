#! /bin/bash

PRGNAME="libfm-qt"

### libfm-qt (components to build desktop file managers)
# Библиотека (Qt-порт libfm), предоставляющая компоненты для сборки файловых
# менеджеров рабочего стола. В LXQt libfm-qt также обрабатывает значки рабочего
# стола и обои.

# Required:    cmake
#              libexif
#              menu-cache
#              qt6
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (components to build desktop file managers)
#
# libfm-qt is the Qt port of libfm, a library providing components to build
# desktop file managers. In LXQt, libfm-qt also handles desktop icons and
# backgrounds
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
