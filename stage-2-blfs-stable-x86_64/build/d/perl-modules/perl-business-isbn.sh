#! /bin/bash

PRGNAME="perl-business-isbn"
ARCH_NAME="Business-ISBN"

### Business::ISBN (work with International Standard Book Numbers)
# Модуль Perl Business::ISBN

# Required:    perl-business-isbn-data
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
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Business/ISBN/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (work with International Standard Book Numbers)
#
# The Business::ISBN module is for work with International Standard Book
# Numbers
#
# Home page: https://metacpan.org/pod/Business::ISBN
# Download:  https://www.cpan.org/authors/id/B/BD/BDFOY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
