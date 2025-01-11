#! /bin/bash

PRGNAME="giflib"

### giflib (Graphics Interchange Format image library)
# Библиотека для чтения и записи изображений в формате GIF (Graphics
# Interchange Format), а также программы для конвертации и работы с GIF файлами

# Required:    xmlto
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-upstream_fixes-1.patch" || exit 1

# удалим ненужную зависимость от ImageMagick
cp pic/gifgrid.gif doc/giflib-logo.gif

make || exit 1
# пакет не имеет набора тестов
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -f "${TMP_DIR}/usr/lib/libgif.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Graphics Interchange Format image library)
#
# The giflib package contains libraries for reading and writing GIF (Graphics
# Interchange Format) as well as programs for converting and working with GIF
# files
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
