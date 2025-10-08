#! /bin/bash

PRGNAME="jasper"
ARCH_NAME="jasper-version"

### JasPer (free implementation of the JPEG-2000 standard)
# програмная реализация кодека, указанного в стандарте JPEG-2000 Part-1, т. е.
# ISO/IEC 15444-1

# Required:    cmake
# Recommended: libjpeg-turbo
# Optional:    freeglut (для создания утилиты jiv)
#              doxygen  (для создания html документации)
#              texlive  (для создания pdf документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir BUILD || exit 1
cd BUILD || exit 1

# удаляем пути поиска встроенной библиотеки
#    -DCMAKE_SKIP_INSTALL_RPATH=YES
cmake                                                              \
    -D CMAKE_INSTALL_PREFIX=/usr                                   \
    -D CMAKE_BUILD_TYPE=Release                                    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON                                 \
    -D JAS_ENABLE_DOC=NO                                           \
    -D ALLOW_IN_SOURCE_BUILD=YES                                   \
    -D CMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (free implementation of the JPEG-2000 standard)
#
# The JasPer Project is an open-source initiative to provide a free
# software-based reference implementation of the codec specified in the
# JPEG-2000 Part-1 standard (i.e., ISO/IEC 15444-1)
#
# Home page: https://www.ece.uvic.ca/~mdadams/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-software/${PRGNAME}/archive/version-${VERSION}/${PRGNAME}-version-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
