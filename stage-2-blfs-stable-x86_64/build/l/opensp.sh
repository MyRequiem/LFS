#! /bin/bash

PRGNAME="opensp"
ARCH_NAME="OpenSP"

### OpenSP (C++ library for using SGML/XML files)
# C++ библиотека для проверки, анализа и управления SGML/XML документами

# Required:    sgml-common
# Recommended: no
# Optional:    xmlto

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# предотвратим некоторые надоедливые сообщения во время работы openjade
sed -i 's/32,/253,/' lib/Syntax.cxx                     || exit 1
sed -i 's/LITLEN          240 /LITLEN          8092/' \
    unicode/{gensyntax.pl,unicode.syn}                  || exit 1

XMLTO="--disable-doc-build"
command -v xmlto &>/dev/null && XMLTO="--enable-doc-build"

./configure                                    \
    --prefix=/usr                              \
    --disable-static                           \
    --enable-http                              \
    "${XMLTO}"                                 \
    --enable-default-catalog=/etc/sgml/catalog \
    --enable-default-search-path=/usr/share/sgml || exit 1

make \
    pkgdatadir="/usr/share/sgml/${PRGNAME}-${VERSION}" \
    docdir="/usr/share/doc/${PRGNAME}-${VERSION}"      \
    mandir=/usr/share/man || exit 1

# make check

make \
    pkgdatadir="/usr/share/sgml/${PRGNAME}-${VERSION}" \
    docdir="/usr/share/doc/${PRGNAME}-${VERSION}"      \
    mandir=/usr/share/man                              \
    install  DESTDIR="${TMP_DIR}" || exit 1

(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv onsgmls   nsgmls
    ln -sfv osgmlnorm sgmlnorm
    ln -sfv ospam     spam
    ln -sfv ospcat    spcat
    ln -sfv ospent    spent
    ln -sfv osx       sx
    ln -sfv osx       sgml2xml
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv libosp.so libsp.so
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ library for using SGML/XML files)
#
# The OpenSP package contains a C++ library for using SGML/XML files. This is
# useful for validating, parsing and manipulating SGML and XML documents.
#
# Home page: http://openjade.sourceforge.net/
# Download:  https://downloads.sourceforge.net/openjade/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

# есть один *.la файл
# /usr/lib/libosp.la
# но он нужен для сборки пакета openjade
