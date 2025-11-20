#! /bin/bash

PRGNAME="libdisplay-info"

### libdisplay-info (get Extended Display Identification Data information)
# Библиотека для получения EDID (Extended Display Identification Data) данных
# дисплея/монитора

# Required:    hwdata
# Recommended: no
# Optional:    no

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (get Extended Display Identification Data information)
#
# The libdisplay-info package provides a set of high-level and low-level
# functions to access detailed Extended Display Identification Data (EDID)
# information
#
# Home page: https://gitlab.freedesktop.org/emersion/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/emersion/${PRGNAME}/-/releases/${VERSION}/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
