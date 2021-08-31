#! /bin/bash

PRGNAME="xml-parser"
ARCH_NAME="XML-Parser"

### XML::Parser (XML::Parser perl module)
# Модуль XML::Parser является Perl-интерфейсом для синтаксического анализатора
# XML документов Expat

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

perl Makefile.PL
make
# make test
make install DESTDIR="${TMP_DIR}"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/XML/Parser/.packlist"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML::Parser perl module)
#
# The XML::Parser module is a Perl interface to James Clark's XML parser,
# Expat.
#
# Home page: https://github.com/chorny/${PRGNAME}
# Download:  https://cpan.metacpan.org/authors/id/T/TO/TODDR/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
