#! /bin/bash

PRGNAME="aalib"
VERSION="1.4rc5"
DIR_VERSION="1.4.0"

### AAlib (ASCII Art library)
# Библиотека, которая отображает любую графику в ASCII символах.

# Required:    no
# Recommended: no
# Optional:    xorg-libraries
#              xorg-fonts
#              slang
#              gpm

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${DIR_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# исправим небольшую проблему с aalib.m4
sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4

./configure                   \
    --prefix=/usr             \
    --infodir=/usr/share/info \
    --mandir=/usr/share/man   \
    --with-ncurses=/usr       \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
