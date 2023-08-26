#! /bin/bash

PRGNAME="perl-xml-libxml-simple"
ARCH_NAME="XML-LibXML-Simple"

### XML::LibXML::Simple (XML::LibXML clone of XML::Simple::XMLin())
# XML::LibXML::Simple Perl модуль

# Required:    perl-xml-libxml
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# стандартная установка
perl Makefile.PL || exit 1
make             || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML::LibXML clone of XML::Simple::XMLin())
#
# The XML::LibXML::Simple module is a rewrite of XML::Simple to use the
# XML::LibXML parser for XML structures, instead of the plain Perl or SAX
# parsers
#
# Home page: https://metacpan.org/dist/XML-LibXML-Simple/view/lib/XML/LibXML/Simple.pod
# Download:  https://www.cpan.org/authors/id/M/MA/MARKOV/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
