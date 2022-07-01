#! /bin/bash

PRGNAME="optipng"

### OptiPNG (Advanced PNG Optimizer)
# Оптимизатор PNG, который повторно сжимает файлы изображений до меньшего
# размера, без потери информации. Утилита также конвертирует внешние форматы
# (BMP, GIF, PNM и TIFF) в оптимизированный PNG, выполняет проверки целостности
# PNG и исправляет ошибки.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                \
    -prefix=/usr           \
    -with-system-zlib      \
    -mandir=/usr/share/man || exit 1

cd src || exit 1
make   || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Advanced PNG Optimizer)
#
# OptiPNG is a PNG optimizer that recompresses image files to a smaller size,
# without losing any information. This program also converts external formats
# (BMP, GIF, PNM and TIFF) to optimized PNG, and performs PNG integrity checks
# and corrections.
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  http://prdownloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
