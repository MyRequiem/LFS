#! /bin/bash

PRGNAME="openjade"

### OpenJade (DSSSL engine for SGML and XML transformations)
# Движок DSSSL для преобразования SGML и XML в RTF, TeX

# Required:    opensp
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/sgml"

# исправим проблемы при сборке с использованием новых компиляторов
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-upstream-1.patch" || exit 1

# исправим проблему сборки с  perl >= 5.16
sed -i -e '/getopts/{N;s#&G#g#;s#do .getopts.pl.;##;}' \
       -e '/use POSIX/ause Getopt::Std;' msggen.pl || exit 1

# устанавливаем CXXFLAGS для предотвращения ошибок сегментации
export CXXFLAGS="${CXXFLAGS:--O2 -g} -fno-lifetime-dse" &&
./configure                                      \
    --prefix=/usr                                \
    --mandir=/usr/share/man                      \
    --enable-http                                \
    --disable-static                             \
    --enable-default-catalog=/etc/sgml/catalog   \
    --enable-default-search-path=/usr/share/sgml \
    --datadir="/usr/share/sgml/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install     DESTDIR="${TMP_DIR}"
make install-man DESTDIR="${TMP_DIR}"

ln -svf openjade       "${TMP_DIR}/usr/bin/jade"
ln -svf libogrove.so   "${TMP_DIR}/usr/lib/libgrove.so"
ln -svf libospgrove.so "${TMP_DIR}/usr/lib/libspgrove.so"
ln -svf libostyle.so   "${TMP_DIR}/usr/lib/libstyle.so"

USR_SHARE_SGML="/usr/share/sgml/${PRGNAME}-${VERSION}"
mkdir -p "${USR_SHARE_SGML}"
install -v -m644 dsssl/catalog         "${USR_SHARE_SGML}/" || exit 1
install -v -m644 dsssl/*.{dtd,dsl,sgm} "${USR_SHARE_SGML}/" || exit 1

OPENJADE_CAT=/etc/sgml/${PRGNAME}-${VERSION}.cat
install-catalog --add "${OPENJADE_CAT}" "${USR_SHARE_SGML}/catalog"  || exit 1
install-catalog --add "/etc/sgml/sgml-docbook.cat" "${OPENJADE_CAT}" || exit 1

echo "SYSTEM \"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd\" \
\"/usr/share/xml/docbook/xml-dtd-4.5/docbookx.dtd\"" >> \
    "${USR_SHARE_SGML}/catalog" || exit 1

cp "${USR_SHARE_SGML}"/* "${TMP_DIR}${USR_SHARE_SGML}/"
cp "${OPENJADE_CAT}"     "${TMP_DIR}/etc/sgml/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (DSSSL engine for SGML and XML transformations)
#
# The OpenJade package contains a DSSSL engine. This is useful for SGML and XML
# transformations into RTF, TeX, SGML and XML.
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
