#! /bin/bash

PRGNAME="libxslt"

### libxslt
# Библиотеки поддержки XSLT для libxml2
# (XSLT - язык, используемый для преобразования документов XML)

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libxslt.html

# Home page: http://xmlsoft.org/XSLT/
# Download:  http://xmlsoft.org/sources/libxslt-1.1.33.tar.gz
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.0/libxslt-1.1.33-security_fix-1.patch

# Required:    libxml2
# Recommended: docbook-xml
#              docbook-xsl
# Optional:    libgcrypt
#              libxml2 (для Python2)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# патчим (исправление безопасности)
patch -Np1 -i /sources/libxslt-1.1.33-security_fix-1.patch || exit 1

# увеличим предел рекурсии с 3000 до 5000 в libxslt (необходимо некоторым
# пакетам для их документации)
sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml}

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML transformation library)
#
# XSLT support for libxml2 (XSLT is a language used for transforming XML
# documents)
#
# Home page: http://xmlsoft.org/XSLT/
# Download:  http://xmlsoft.org/sources/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
