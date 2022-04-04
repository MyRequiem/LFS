#! /bin/bash

PRGNAME="perl-params-validationcompiler"
ARCH_NAME="Params-ValidationCompiler"

### Params::ValidationCompiler (build an optimized subroutine parameter validator)
# Params::ValidationCompiler Perl модуль

# Required:    perl-exception-class
#              perl-specio
# Recommended: no
# Optional:    perl-test-without-module       (для тестов)
#              perl-test2-plugin-nowarnings   (для тестов)

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
# Package: ${PRGNAME} (build an optimized subroutine parameter validator)
#
# Params::ValidationCompiler builds an optimized subroutine parameter validator
#
# Home page: https://metacpan.org/pod/Params::ValidationCompiler
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
