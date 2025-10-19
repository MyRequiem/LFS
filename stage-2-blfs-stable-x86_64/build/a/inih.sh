#! /bin/bash

PRGNAME="inih"

### inih.sh (INI Not Invented Here)
# Простой парсер .INI файлов, написанный на C

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d r -f 2)"

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
# Package: ${PRGNAME} (INI Not Invented Here)
#
# Simple .INI file parser written in C
#
# Home page: https://github.com/benhoyt/${PRGNAME}
# Download:  https://github.com/benhoyt/${PRGNAME}/archive/r${VERSION}/${PRGNAME}-r${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
