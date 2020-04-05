#! /bin/bash

PRGNAME="jasper"

### JasPer (free implementation of the JPEG-2000 standard)
# програмная реализация кодека, указанного в стандарте JPEG-2000 Part-1, т. е.
# ISO/IEC 15444-1

# http://www.linuxfromscratch.org/blfs/view/9.0/general/jasper.html

# Home page: http://www.ece.uvic.ca/~mdadams/jasper/
# Download:  http://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz

# Required:    cmake
# Recommended: libjpeg-turbo
# Optional:    freeglut (для создания утилиты jiv)
#              doxygen  (для создания html документации)
#              texlive  (для создания pdf документации)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# директория build уже существует в дереве исходного кода, поэтому создаем
# _build
mkdir _build || exit 1
cd _build || exit 1

# удаляем пути поиска встроенной библиотеки
#    -DCMAKE_SKIP_INSTALL_RPATH=YES
# отключаем пересоздание PDF документации, если установлен пакет texlive
#    -DJAS_ENABLE_DOC=NO
cmake                              \
    -DCMAKE_INSTALL_PREFIX=/usr    \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCMAKE_SKIP_INSTALL_RPATH=YES \
    -DJAS_ENABLE_DOC=NO            \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (free implementation of the JPEG-2000 standard)
#
# The JasPer Project is an open-source initiative to provide a free
# software-based reference implementation of the codec specified in the
# JPEG-2000 Part-1 standard (i.e., ISO/IEC 15444-1)
#
# Home page: http://www.ece.uvic.ca/~mdadams/${PRGNAME}/
# Download:  http://www.ece.uvic.ca/~frodo/${PRGNAME}/software/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
