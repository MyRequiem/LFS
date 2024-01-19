#! /bin/bash

PRGNAME="imlib2"

### imlib2 (successor to Imlib)
# Графическая библиотека для быстрой загрузки, сохранения, рендеринга,
# модификации изображений

# Required:    xorg-libraries
# Recommended: giflib
# Optional:    doxygen
#              libpng
#              libjpeg-turbo
#              libtiff
#              x265
#              libid3tag (https://sourceforge.net/projects/mad/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

API_DOCS="false"
# command -v doxygen &>/dev/null && API_DOCS="true"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

if [[ "x${API_DOCS}" == "xtrue" ]]; then
    DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d         "${TMP_DIR}${DOC_DIR}/html"
    install -v -m644 doc/html/* "${TMP_DIR}${DOC_DIR}/html"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (successor to Imlib)
#
# imlib2 is a graphics library for fast file loading, saving, rendering and
# manipulation, which load image files from disk in one of many formats, save
# images to disk in one of many formats, render image data onto other images,
# render images to an X-Windows drawable, produce pixmaps and pixmap masks of
# images, apply filters to images, rotate images, accept RGBA data for images,
# scale images, and more.
#
# Home page: https://www.enlightenment.org
# Download:  https://downloads.sourceforge.net/enlightenment/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
