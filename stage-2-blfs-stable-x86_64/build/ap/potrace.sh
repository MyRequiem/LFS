#! /bin/bash

PRGNAME="potrace"

### Potrace (bitmap utility)
# Утилита для преобразования растровых изображений (PBM, PGM, PPM или BMP) в
# один из нескольких векторных форматов (например в EPS)

# Required:    no
# Recommended: llvm
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --disable-static  \
    --enable-a4       \
    --enable-metric   \
    --with-libpotrace \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}/usr/share/" || exit 1
    rm -rf doc
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (bitmap utility)
#
# Potrace is a utility for tracing a bitmap, which means, transforming a bitmap
# into a smooth, scalable image. The input is a bitmap (PBM, PGM, PPM, or BMP
# format), and the default output is an encapsulated PostScript file (EPS). A
# typical use is to create EPS files from scanned data, such as company or
# university logos, handwritten notes, etc. The resulting image is not "jaggy"
# like a bitmap, but smooth. It can then be rendered at any resolution.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
