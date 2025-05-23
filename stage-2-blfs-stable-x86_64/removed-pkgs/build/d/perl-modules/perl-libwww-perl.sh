#! /bin/bash

PRGNAME="perl-libwww-perl"
ARCH_NAME="libwww-perl"

### LWP (The World-Wide Web library for Perl)
# LWP Perl модуль

# Required:    perl-file-listing
#              perl-http-cookies
#              perl-http-daemon
#              perl-http-negotiate
#              perl-html-parser
#              perl-net-http
#              perl-try-tiny
#              perl-www-robotrules
# Recommended: --- для тестов ---
#              perl-test-fatal
#              perl-test-needs
#              perl-test-requiresinternet
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
# Package: ${PRGNAME} (The World-Wide Web library for Perl)
#
# The libwww-perl collection is a set of Perl modules which provides a simple
# and consistent application programming interface (API) to the World-Wide Web.
# The main focus of the library is to provide classes and functions that allow
# you to write WWW clients. The library also contains modules that are of more
# general use and even classes that help you implement simple HTTP servers.
#
# Home page: https://metacpan.org/pod/LWP
# Download:  https://www.cpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
