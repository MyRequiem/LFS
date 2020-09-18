#! /bin/bash

PRGNAME="libxslt"

### libxslt (XML transformation library)
# Библиотеки поддержки XSLT для libxml2
# (XSLT - язык, используемый для преобразования документов XML)

# http://www.linuxfromscratch.org/blfs/view/stable/general/libxslt.html

# Home page: http://xmlsoft.org/XSLT/
# Download:  http://xmlsoft.org/sources/libxslt-1.1.34.tar.gz

# Required:    libxml2
# Recommended: docbook-xml
#              docbook-xsl
# Optional:    libgcrypt
#              python2-libxml2

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# увеличим предел рекурсии с 3000 до 5000 в libxslt (необходимо некоторым
# пакетам для их документации)
sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} || exit 1

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
