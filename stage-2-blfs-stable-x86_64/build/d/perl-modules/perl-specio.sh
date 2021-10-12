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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Specio/.packlist"

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
