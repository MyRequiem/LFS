#! /bin/bash

PRGNAME="totem-pl-parser"

### Totem PL Parser (totem playlist parser)
# Анализатор плейлистов - это простая библиотека на основе GObject для анализа
# множество форматов плейлистов, а также для их сохранения

# Required:    no
# Recommended: glib
#              libarchive
#              libgcrypt
# Optional:    cmake
#              gtk-doc
#              gvfs                 (для некоторых тестов)
#              lcov                 (https://github.com/linux-test-project/lcov)
#              libquvi              >= 0.9.1 (https://sourceforge.net/projects/quvi)
#              lua-socket           (для тестов) https://github.com/diegonehab/luasocket

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (totem playlist parser)
#
# The Totem PL Parser package contains a simple GObject-based library used to
# parse multiple playlist formats
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
