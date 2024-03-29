#! /bin/bash

PRGNAME="perl-test2-suite"
ARCH_NAME="Test2-Suite"

### Test2::Suite (rich set of tools built upon the Test2 framework)
# Test2::Suite Perl модуль

# Required:    perl-module-pluggable
#              perl-scope-guard
#              perl-sub-info
#              perl-term-table
# Recommended: no
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
# Package: ${PRGNAME} (rich set of tools built upon the Test2 framework)
#
# Test2::Suite is a distribution with a rich set of tools built upon the Test2
# framework
#
# Home page: https://metacpan.org/pod/Test2::Suite
# Download:  https://cpan.metacpan.org/authors/id/E/EX/EXODIST/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
