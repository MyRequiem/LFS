#! /bin/bash

PRGNAME="perl-datetime-calendar-julian"
ARCH_NAME="DateTime-Calendar-Julian"

### DateTime::Calendar::Julian (dates in the Julian calendar)
# DateTime::Calendar::Julian Perl модуль

# Required:    perl-datetime
# Recommended: no
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
PACKLIST="site_perl/auto/DateTime/Calendar/Julian/.packlist"
sed -e "s|${TMP_DIR}||" -i "${TMP_DIR}${PERL_LIB_PATH}/${PACKLIST}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dates in the Julian calendar)
#
# DateTime::Calendar::Julian implements the Julian Calendar
#
# Home page: https://metacpan.org/pod/DateTime::Calendar::Julian
# Download:  https://www.cpan.org/authors/id/W/WY/WYANT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
