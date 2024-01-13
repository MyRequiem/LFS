#! /bin/bash

PRGNAME="atkmm"

### Atkmm (C++ bindings for ATK)
# C++ bindings для ATK (accessibility toolkit library)

# Required:    at-spi2-core
#              glibmm
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

mkdir build
cd build || exit 1

meson                               \
    --prefix=/usr                   \
    --buildtype=release             \
    -Dbuild-documentation="${DOCS}" \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ bindings for ATK)
#
# Atkmm is the official C++ interface for the ATK (accessibility toolkit
# library)
#
# Home page: http://www.gtkmm.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
