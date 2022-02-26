#! /bin/bash

PRGNAME="id3lib"

### id3lib (ID3 tag manipulation library)
# Библиотека для чтения, записи и управления id3v1 и id3v2 данными мультимедиа

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}${MAN}"

# пакет больше не обновляется - последнее обновление 2003 года, поэтому
# применяем объединенную серию исправлений, позволяющих собирать пакет на
# современных системах
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated_patches-1.patch" || exit 1

libtoolize -fc                || exit 1
aclocal                       || exit 1
autoconf                      || exit 1
automake --add-missing --copy || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

cp doc/man/* "${TMP_DIR}${MAN}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ID3 tag manipulation library)
#
# id3lib is a library for reading, writing and manipulating id3v1 and id3v2
# multimedia data containers.
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
