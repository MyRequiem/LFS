#! /bin/bash

PRGNAME="XML-Parser"

### XML::Parser
# Модуль XML::Parser является Perl-интерфейсом для синтаксического анализатора
# XML документов Expat

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/xml-parser.html

# Home page: https://github.com/chorny/XML-Parser
# Download:  https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.44.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

perl Makefile.PL
make
make test
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML::Parser perl module)
#
# The XML::Parser module is a Perl interface to James Clark's XML parser,
# Expat.
#
# Home page: https://github.com/chorny/${PRGNAME}
# Download:  https://cpan.metacpan.org/authors/id/T/TO/TODDR/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
