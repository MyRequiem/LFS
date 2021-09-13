#! /bin/bash

PRGNAME="perl-test2-plugin-nowarnings"
ARCH_NAME="Test2-Plugin-NoWarnings"

### Test2::Plugin::NoWarnings (fail if tests warn)
# Test2::Plugin::NoWarnings Perl модуль

# Required:    perl-test2-suite
# Recommended: perl-ipc-run3 (для тестов)
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
PACKLIST="/site_perl/auto/Test2/Plugin/NoWarnings/.packlist"
sed -e "s|${TMP_DIR}||" -i "${TMP_DIR}${PERL_LIB_PATH}${PACKLIST}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fail if tests warn)
#
# Test2::Plugin::NoWarnings causes tests to fail if there are any warnings
# while they run
#
# Home page: https://metacpan.org/pod/Test2::Plugin::NoWarnings
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
