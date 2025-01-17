#! /bin/bash

PRGNAME="perl-package-stash"
ARCH_NAME="Package-Stash"

### Package::Stash (routines for manipulating stashes)
# Package::Stash Perl модуль

# Required:    perl-dist-checkconflicts
#              perl-module-implementation
# Recommended: --- для тестов ---
#              perl-cpan-meta-check
#              perl-test-fatal
#              perl-test-needs
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
