#! /bin/bash

PRGNAME="lcms"

### Little CMS (Little Color Management System engine, version 1)
# Компактный движок управления цветом. Особое внимание уделяется точности и
# производительности. Использует современный стандарт International Color
# Consortium standard (ICC)

# Required:    no
# Recommended: no
# Optional:    libtiff
#              libjpeg-turbo
#              python2
#              swig

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-cve_2013_4276-1.patch" || exit 1

WITH_PYTHON="--without-python"
[ -x /usr/bin/python2 ] && [ -x /usr/bin/swig ] && WITH_PYTHON="--with-python"

./configure          \
    --prefix=/usr    \
    "${WITH_PYTHON}" \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Little Color Management System engine, version 1)
#
# The Little Color Management System is a small-footprint color management
# engine, with special focus on accuracy and performance. It uses the
# International Color Consortium standard (ICC), which is the modern standard
# for color management.
#
# Home page: https://www.littlecms.com/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
