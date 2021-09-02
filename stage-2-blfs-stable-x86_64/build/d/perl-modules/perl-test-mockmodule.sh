#! /bin/bash

PRGNAME="perl-test-mockmodule"
ARCH_NAME="Test-MockModule"

### Test::MockModule (Override subroutines in a module)
# Perl модуль, позволяющий временно переопределять подпрограммы в других
# пакетах для юнит-тестирования

# Required:    perl-module-build
#              perl-super
# Recommended: perl-test-warnings (для тестов)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2-)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

perl Build.PL || exit 1
./Build       || exit 1
# ./Build test
./Build install destdir="${TMP_DIR}"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Test/MockModule/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Override subroutines in a module)
#
# Test::MockModule lets you temporarily redefine subroutines in other packages
# for the purposes of unit testing.
#
# Home page: https://metacpan.org/pod/Test::MockModule
# Download:  https://cpan.metacpan.org/authors/id/G/GF/GFRANKS/${ARCH_NAME}-v${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
