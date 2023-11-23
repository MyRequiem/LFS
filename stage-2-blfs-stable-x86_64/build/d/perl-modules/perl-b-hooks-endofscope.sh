#! /bin/bash

PRGNAME="perl-b-hooks-endofscope"
ARCH_NAME="B-Hooks-EndOfScope"

### B::Hooks::EndOfScope (execute code after a scope finished compilation)
# B::Hooks::EndOfScope Perl модуль

# Required:    perl-module-implementation
#              perl-sub-exporter-progressive
#              perl-variable-magic
# Recommended: perl-try-tiny (для тестов)
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
# Package: ${PRGNAME} (execute code after a scope finished compilation)
#
# B::Hooks::EndOfScope allows you to execute code when perl finished compiling
# the surrounding scope
#
# Home page: https://metacpan.org/pod/B::Hooks::EndOfScope
# Download:  https://cpan.metacpan.org/authors/id/E/ET/ETHER/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
