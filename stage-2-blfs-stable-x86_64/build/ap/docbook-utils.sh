#! /bin/bash

PRGNAME="docbook-utils"

### DocBook-utils (scripts collection to convert and analyze SGML documents)
# Набор служебных скриптов для преобразования из DocBook или других форматов
# SGML в HTML, man, info, RTF и многие другие форматы. Так же используется для
# анализа SGML документов в целом и файлов DocBook в частности.

# Required:    openjade
#              docbook-dsssl
#              docbook-dtd3
# Recommended: no
# Optional:    perl-sgmlspm             (для конвертации в man и texinfo)
#              lynx или links или w3m   (http://w3m.sourceforge.net/) для конвертации в ASCII text

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим синтаксис в сценарии jw (Jade Wrapper) для grep
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-grep_fix-1.patch" || exit 1

# изменим каталог установки HTML-документов
sed -i 's:/html::' doc/HTML/Makefile.in

./configure       \
    --prefix=/usr \
    --mandir=/usr/share/man || exit 1

make || exit 1
# пакет не имет набора тестов
make docdir=/usr/share/doc install DESTDIR="${TMP_DIR}"

# установим некоторые ссылки для совместимости
for DOCTYPE in html ps dvi man pdf rtf tex texi txt; do
    ln -svf "docbook2${DOCTYPE}" "${TMP_DIR}/usr/bin/db2${DOCTYPE}"
done

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts collection to convert and analyze SGML documents)
#
# The DocBook-utils package is a collection of utility scripts used to convert
# and analyze SGML documents in general, and DocBook files in particular. The
# scripts are used to convert from DocBook or other SGML formats into
# ?classical? file formats like HTML, man, info, RTF and many more. There's
# also a utility to compare two SGML files and only display the differences in
# markup. This is useful for comparing documents prepared for different
# languages.
#
# Home page: https://sourceware.org/docbook-tools/
# Download:  https://sourceware.org/ftp/docbook-tools/new-trials/SOURCES/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
