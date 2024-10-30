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

DOCS="false"

make || exit 1
# make check
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

# удалим не используемую в BLFS статическую библиотеку
rm -f "${TMP_DIR}/usr/lib/libgif.a"

if [[ "x${DOCS}" == "xtrue"  ]]; then
    find doc \( \
                -name Makefile\* -o \
                -name \*.1          \
                -name \*.xml     -o \
                -name \*.in      -o \
             \) \
        -exec rm {} \;

    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -dm755 "${TMP_DIR}${DOC_PATH}"
    cp -R doc/*    "${TMP_DIR}${DOC_PATH}"
fi

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
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
