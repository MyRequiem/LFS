#! /bin/bash

PRGNAME="perl-list-someutils-xs"
ARCH_NAME="List-SomeUtils-XS"

### List::SomeUtils::XS (XS implementation for List::SomeUtils)
# List::SomeUtils::XS Perl модуль

# Required:    no
# Recommended: --- для тестов ---
#              perl-test-leaktrace
#              perl-test-warnings
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# стандартная установка
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
# Package: ${PRGNAME} (XS implementation for List::SomeUtils)
#
# List::SomeUtils::XS is a (faster) XS (eXternal Subroutine) implementation for
# List::SomeUtils
#
# Home page: https://metacpan.org/pod/List::SomeUtils::XS
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
