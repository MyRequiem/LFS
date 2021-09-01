#! /bin/bash

PRGNAME="perl-autovivification"
ARCH_NAME="$(echo "${PRGNAME}" | cut -d - -f 2)"

### perl-autovivification (Perl module for disable autovivification)
# Perl модуль, позволяющий отключить автоматическое создание и заполнение новых
# массивов и хэшей всякий раз, когда разыменовываются неопределенные переменные

# Required:    no
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
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/autovivification/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl module for disable autovivification)
#
# This module allows you disable autovivification (the automatic creation and
# population of new arrays and hashes whenever undefined variables are
# dereferenced), and optionally throw a warning or an error when it would have
# occurred.
#
# Home page: https://metacpan.org/pod/${ARCH_NAME}
# Download:  https://www.cpan.org/authors/id/V/VP/VPIT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
