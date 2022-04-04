#! /bin/bash

PRGNAME="perl-module-implementation"
ARCH_NAME="Module-Implementation"

### Module::Implementation (loads one of several alternate module implementations)
# Module::Implementation Perl модуль

# Required:    perl-module-runtime
#              perl-try-tiny
# Recommended: perl-test-fatal    (для тестов)
#              perl-test-requires (для тестов)
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
# Package: ${PRGNAME} (loads one of several alternate module implementations)
#
# Module::Implementation loads one of several alternate underlying
# implementations of a module (e.g. eXternal Subroutine or pure Perl, or an
# implementation for a given OS)
#
# Home page: https://metacpan.org/pod/Module::Implementation
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
