#! /bin/bash

PRGNAME="aalib"
VERSION="1.4rc5"
DIR_VERSION="1.4.0"

### AAlib (ASCII Art library)
# Библиотека, которая отображает любую графику в ASCII символах.

# http://www.linuxfromscratch.org/blfs/view/stable/general/aalib.html

# Home page: http://aa-project.sourceforge.net/aalib/
# Download:  https://downloads.sourceforge.net/aa-project/aalib-1.4rc5.tar.gz

# Required: no
# Optional: slang
#           gpm

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="/root/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${DIR_VERSION}" || exit 1

# исправим небольшую проблему с aalib.m4
sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4

./configure                   \
    --prefix=/usr             \
    --infodir=/usr/share/info \
    --mandir=/usr/share/man   \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ASCII Art library)
#
# AA-lib is an ASCII art graphics library which render any graphic into ASCII
# Art. Internally, the AA-lib API is similar to other graphics libraries, but
# it renders the the output into ASCII art.
#
# Home page: http://aa-project.sourceforge.net/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/aa-project/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
