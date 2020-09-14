#! /bin/bash

PRGNAME="potrace"

### Potrace (Transforming bitmaps into vector graphics)
# Утилиты для преобразование растровых bitmap изображений (PBM, PGM, PPM или
# BMP) в векторные форматы. Типичное использование - создание файлов EPS
# (PostScript) из отсканированных изображений в любом разрешении.

# http://www.linuxfromscratch.org/blfs/view/stable/general/potrace.html

# Home page: http://potrace.sourceforge.net
# Download:  https://downloads.sourceforge.net/potrace/potrace-1.16.tar.gz

# Required:    no
# Recommended: llvm
# Optional:    no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# формат A4 по умолчанию
#    --enable-a4
# используем сантиметры как метрические единицы по умолчанию
#    --enable-metric
# устанавливать библиотеку libpotrace.so и заголовочные файлы
#    --with-libpotrace
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --enable-a4       \
    --enable-metric   \
    --with-libpotrace \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Transforming bitmaps into vector graphics)
#
# Potrace is a utility for tracing a bitmap, which means, transforming a bitmap
# into a smooth, scalable image (several vector file formats). The input is a
# bitmap (PBM, PGM, PPM, or BMP format), and the default output is an
# encapsulated PostScript file (EPS). A typical use is to create EPS files from
# scanned data. The resulting image is not "jaggy" like a bitmap, but smooth.
# It can then be rendered at any resolution.
#
# Home page: http://${PRGNAME}.sourceforge.net
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
