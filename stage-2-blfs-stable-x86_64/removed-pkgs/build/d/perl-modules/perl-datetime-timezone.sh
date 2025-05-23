#! /bin/bash

PRGNAME="perl-datetime-timezone"
ARCH_NAME="DateTime-TimeZone"

### DateTime::TimeZone (time zone object base class and factory)
# DateTime::TimeZone Perl модуль

# Required:    perl-class-singleton
#              perl-module-runtime
#              perl-params-validationcompiler
# Recommended: --- для тестов ---
#              perl-test-fatal
#              perl-test-requires
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
# Package: ${PRGNAME} (time zone object base class and factory)
#
# This class is the base class for all time zone objects. A time zone is
# represented internally as a set of observances, each of which describes the
# offset from GMT for a given time period.
#
# Home page: https://metacpan.org/pod/DateTime::TimeZone
# Download:  https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
