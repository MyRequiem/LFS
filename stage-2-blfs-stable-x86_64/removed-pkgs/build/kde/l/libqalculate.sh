#! /bin/bash

PRGNAME="libqalculate"

### libqalculate (functions for a multi-purpose calculator)
# Набор функций для универсального калькулятора

# Required:    curl
#              icu
#              libxml2
# Recommended: no
# Optional:    doxygen
#              gnuplot      (http://www.gnuplot.info/download.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (functions for a multi-purpose calculator)
#
# The libqalculate package contains a library that provides functions for a
# multi-purpose calculator
#
# Home page: https://github.com/Qalculate/${PRGNAME}/
# Download:  https://github.com/Qalculate/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
