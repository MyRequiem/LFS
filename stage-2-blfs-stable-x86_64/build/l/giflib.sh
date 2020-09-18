#! /bin/bash

PRGNAME="giflib"

### giflib (Graphics Interchange Format image library)
# Библиотеки для чтения и записи GIF, а также программы для конвертации и
# работы с GIF-файлами.

# http://www.linuxfromscratch.org/blfs/view/stable/general/giflib.html

# Home page: http://giflib.sourceforge.net/
# Download:  https://sourceforge.net/projects/giflib/files/giflib-5.2.1.tar.gz

# Required: xmlto
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

make
# пакет не содержит набора тестов
make PREFIX=/usr install
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

find doc \( -name "Makefile*" -o -name "*.1" -o -name "*.xml" \) -exec \
    rm -v {} \;

install -v -dm755 "${DOCS}"
cp -v -R doc/* "${DOCS}"
cp -v -R doc/* "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Graphics Interchange Format image library)
#
# A library to load and save (uncompressed only) images using GIF, or Graphics
# Interchange Format. GIF was introduced by CompuServe in 1987, but is still
# widely used today (especially on web pages.)
#
# Home page: http://giflib.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
