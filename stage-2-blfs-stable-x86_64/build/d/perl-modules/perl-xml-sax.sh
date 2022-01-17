#! /bin/bash

PRGNAME="perl-xml-sax"
ARCH_NAME="XML-SAX"

### XML::SAX (simple API for XML)
# XML::SAX Perl модуль

# Required:    libxml2
#              perl-xml-namespacesupport
#              perl-xml-sax-base
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Perl спросит, хотим ли мы, чтобы он изменил ParserDetails.ini, отвечаем 'yes'
yes | perl Makefile.PL || exit 1
make                   || exit 1
# make test

# устанавливаем сразу в систему, иначе будет ошибка 'make install' во временную
# директорию:
# Can't locate XML/SAX.pm in @INC (you may need to install the XML::SAX module)
# (@INC contains: /usr/lib/perl5/5.xx/site_perl /usr/lib/perl5/5.xx/vendor_perl
# /usr/lib/perl5/5.xx/core_perl)
# BEGIN failed--compilation aborted.
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (simple API for XML)
#
# XML::SAX is a SAX parser access API for Perl. It includes classes and APIs
# required for implementing SAX drivers, along with a factory class for
# returning any SAX parser installed on the user's system
#
# Home page: https://metacpan.org/pod/XML::SAX
# Download:  https://cpan.metacpan.org/authors/id/G/GR/GRANTM/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
