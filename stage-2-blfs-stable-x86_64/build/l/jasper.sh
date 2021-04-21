#! /bin/bash

PRGNAME="jasper"

### JasPer (free implementation of the JPEG-2000 standard)
# програмная реализация кодека, указанного в стандарте JPEG-2000 Part-1, т. е.
# ISO/IEC 15444-1

# Required:    cmake
# Recommended: libjpeg-turbo
# Optional:    freeglut (для создания утилиты jiv)
#              doxygen  (для создания html документации)
#              texlive  (для создания pdf документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-version-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir BUILD || exit 1
cd BUILD || exit 1

# если установлен пакет doxygen и/или texlive, то собираем документацию
ENABLE_DOC="NO"
# command -v doxygen &>/dev/null && ENABLE_DOC="YES"
# command -v texdoc  &>/dev/null && ENABLE_DOC="YES"

# удаляем пути поиска встроенной библиотеки
#    -DCMAKE_SKIP_INSTALL_RPATH=YES
cmake                                                             \
    -DCMAKE_INSTALL_PREFIX=/usr                                   \
    -DCMAKE_BUILD_TYPE=Release                                    \
    -DCMAKE_SKIP_INSTALL_RPATH=YES                                \
    -DJAS_ENABLE_DOC="${ENABLE_DOC}"                              \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
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
# Home page: http://www.ece.uvic.ca/~mdadams/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}-software/${PRGNAME}/archive/version-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
