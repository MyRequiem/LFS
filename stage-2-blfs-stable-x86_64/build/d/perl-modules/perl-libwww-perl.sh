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
# Recommended: perl-test-fatal            (для тестов)
#              perl-test-needs            (для тестов)
#              perl-test-requiresinternet (для тестов)
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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/libwww/perl/.packlist"

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
# Download:  https://cpan.metacpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
