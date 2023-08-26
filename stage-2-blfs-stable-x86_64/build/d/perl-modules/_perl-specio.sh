#! /bin/bash

PRGNAME="perl-specio"
ARCH_NAME="Specio"

### Specio (type constraints and coercions for Perl)
# Specio Perl модуль

# Required:    perl-devel-stacktrace
#              perl-eval-closure
#              perl-module-runtime
#              perl-role-tiny
#              perl-sub-quote
#              perl-try-tiny
# Recommended: perl-mro-compat          (для тестов)
#              perl-test-fatal          (для тестов)
#              perl-test-needs          (для тестов)
# Optional:    perl-namespace-autoclean (для тестов)

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
# Package: ${PRGNAME} (type constraints and coercions for Perl)
#
# Specio provides classes for representing type constraints and coercion, along
# with syntax sugar for declaring them
#
# Home page: https://metacpan.org/pod/Specio
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
