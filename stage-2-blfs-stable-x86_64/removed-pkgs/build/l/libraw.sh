#! /bin/bash

PRGNAME="libraw"
ARCH_NAME="LibRaw"

### libraw (library for reading RAW files)
# Библиотека для чтения файлов RAW (файлы цифровых камер)

# Required:    no
# Recommended: libjpeg-turbo
#              jasper
#              lcms2
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --enable-jpeg    \
    --enable-jasper  \
    --enable-lcms    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for reading RAW files)
#
# Libraw is a library for reading RAW files obtained from digital cameras
# (CRW/CR2, NEF, RAF, DNG, and others)
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/data/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
