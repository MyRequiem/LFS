#! /bin/bash

PRGNAME="djvulibre"

### DjVuLibre (web-centric document and image format)
# Реализует формат цифровых документов и изображений DjVu. Содержимое DjVu
# быстрее загружается, отображается и рендерится, выглядит лучше на экране и
# потребляет меньше клиентских ресурсов, чем конкурирующие форматы.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (web-centric document and image format)
#
# DjVu is a web-centric format and software platform for distributing documents
# and images. DjVu content downloads faster, displays and renders faster, looks
# nicer on a screen, and consume less client resources than competing formats.
# DjVu was originally developed at AT&T Labs-Research by Leon Bottou, Yann
# LeCun, Patrick Haffner, and many others.
#
# Home page: http://djvu.sourceforge.net/
# Download:  http://downloads.sourceforge.net/djvu/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
