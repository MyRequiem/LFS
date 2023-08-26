#! /bin/bash

PRGNAME="perl-datetime-locale"
ARCH_NAME="DateTime-Locale"

### DateTime::Locale (localization support for DateTime.pm)
# DateTime::Locale Perl модуль

# Required:    perl-dist-checkconflicts
#              perl-file-sharedir
#              perl-namespace-autoclean
#              perl-params-validationcompiler
# Recommended: perl-cpan-meta-check    (для тестов)
#              perl-ipc-system-simple  (для тестов)
#              perl-test-file-sharedir (для тестов)
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
# Package: ${PRGNAME} (localization support for DateTime.pm)
#
# DateTime::Locale provides localization support for DateTime
#
# Home page: https://metacpan.org/pod/DateTime::Locale
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
