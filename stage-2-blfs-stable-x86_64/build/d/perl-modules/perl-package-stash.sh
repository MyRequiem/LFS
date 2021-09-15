#! /bin/bash

PRGNAME="perl-package-stash"
ARCH_NAME="Package-Stash"

### Package::Stash (routines for manipulating stashes)
# Package::Stash Perl модуль

# Required:    perl-dist-checkconflicts
#              perl-module-implementation
# Recommended: perl-cpan-meta-check (для тестов)
#              perl-test-fatal      (для тестов)
#              perl-test-needs      (для тестов)
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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Package/Stash/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (routines for manipulating stashes)
#
# Manipulating stashes (Perl's symbol tables) is occasionally necessary, but
# incredibly messy, and easy to get wrong. This module hides all of that behind
# a simple API
#
# Home page: https://metacpan.org/pod/Package::Stash
# Download:  https://cpan.metacpan.org/authors/id/E/ET/ETHER/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
