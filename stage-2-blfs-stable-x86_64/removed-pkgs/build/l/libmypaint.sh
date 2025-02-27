#! /bin/bash

PRGNAME="libmypaint"

### libmypaint (brushstroke rendering library)
# Библиотекa для создания графических мазков, которая используется MyPaint,
# Gimp и другими проектами

# Required:    json-c
# Recommended: glib
# Optional:    doxygen                  (для создания XML документации)
#              gegl                     https://download.gimp.org/pub/gegl/0.3/ (только версии 0.3.xx)
#              gperftools               (https://github.com/gperftools/gperftools)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (brushstroke rendering library)
#
# The libmypaint package, a.k.a. "brushlib", is a library for making
# brushstrokes which is used by MyPaint, Gimp and other projects.
#
# Home page: https://github.com/mypaint/${PRGNAME}/
# Download:  https://github.com/mypaint/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
