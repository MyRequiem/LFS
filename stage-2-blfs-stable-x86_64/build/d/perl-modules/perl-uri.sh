#! /bin/bash

PRGNAME="perl-uri"
ARCH_NAME="URI"

### URI (absolute and relative Uniform Resource Identifiers)
# URI Perl модуль

# Required:    no
# Recommended: perl-test-needs (для тестов)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

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
# Package: ${PRGNAME} (absolute and relative Uniform Resource Identifiers)
#
# This module implements the URI class. Objects of this class represent
# "Uniform Resource Identifier references" as specified in RFC 2396 (and
# updated by RFC 2732). A Uniform Resource Identifier is a compact string of
# characters that identifies an abstract or physical resource. A Uniform
# Resource Identifier can be further classified as either a Uniform Resource
# Locator (URL) or a Uniform Resource Name (URN). The distinction between URL
# and URN does not matter to the URI class interface. A "URI-reference" is a
# URI that may have additional information attached in the form of a fragment
# identifier.
#
# Home page: https://metacpan.org/pod/URI
# Download:  https://www.cpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
