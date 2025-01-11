#! /bin/bash

PRGNAME="lcms2"

### Little CMS v2 (Little Color Management System engine, version 2)
# Компактный движок управления цветом. Особое внимание уделяется точности и
# производительности. Использует современный стандарт International Color
# Consortium standard (ICC)

# Required:    no
# Recommended: no
# Optional:    libjpeg-turbo
#              libtiff

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

REPO_NAME="$(echo "${PRGNAME}" | cut -d 2 -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Little Color Management System engine, version 2)
#
# The Little Color Management System is a small-footprint color management
# engine, with special focus on accuracy and performance. It uses the
# International Color Consortium standard (ICC), which is the modern standard
# for color management.
#
# Home page: https://www.littlecms.com/
# Download:  https://github.com/mm2/Little-CMS/releases/download/${REPO_NAME}${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
