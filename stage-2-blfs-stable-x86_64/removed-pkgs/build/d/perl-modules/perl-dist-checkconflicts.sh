#! /bin/bash

PRGNAME="perl-dist-checkconflicts"
ARCH_NAME="Dist-CheckConflicts"

### Dist::CheckConflicts (declare version conflicts for your dist)
# Dist::CheckConflicts Perl модуль

# Required:    perl-module-runtime
# Recommended: perl-test-fatal (для тестов)
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
# Package: ${PRGNAME} (declare version conflicts for your dist)
#
# Dist::CheckConflicts declares version conflicts for a distribution, to
# support post-install updates of dependant distributions
#
# Home page: https://metacpan.org/pod/Dist::CheckConflicts
# Download:  https://cpan.metacpan.org/authors/id/D/DO/DOY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
