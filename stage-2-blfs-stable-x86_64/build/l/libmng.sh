#! /bin/bash

PRGNAME="libmng"

### libmng (Multiple-image Network Graphics library)
# Библиотека MNG (Multiple-image Network Graphics) разработана с той же
# модульной философией что и PNG и предназначеная для предоставления тех
# анимационных возможностей, которые не имеются в PNG

# Required:    libjpeg-turbo
#              lcms2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# документация
if [[ "x${DOCS}" == "xtrue" ]]; then
    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d "${TMP_DIR}${DOC_PATH}"
    install -v -m644 doc/libmng.txt "${TMP_DIR}${DOC_PATH}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Multiple-image Network Graphics library)
#
# This is libmng, the MNG reference library. MNG is short for Multiple-image
# Network Graphics. Designed with the same modular philosophy as PNG and by
# many of the same people, MNG is intended to provide a home for all of the
# multi-image (animation) capabilities that have no place in PNG
#
# Home page: http://www.libpng.org/pub/mng/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
