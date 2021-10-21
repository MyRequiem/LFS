#! /bin/bash

PRGNAME="perl-datetime-format-builder"
ARCH_NAME="DateTime-Format-Builder"

### DateTime::Format::Builder (create DateTime parser classes and objects)
# DateTime::Format::Builder Perl модуль

# Required:    perl-datetime-format-strptime
#              perl-params-validate
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
PACKLIST="site_perl/auto/DateTime/Format/Builder/.packlist"
sed -e "s|${TMP_DIR}||" -i "${TMP_DIR}${PERL_LIB_PATH}/${PACKLIST}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (create DateTime parser classes and objects)
#
# DateTime::Format::Builder created DateTime parser classes and objects
#
# Home page: https://metacpan.org/pod/DateTime::Format::Builder
# Download:  https://www.cpan.org/authors/id/D/DR/DROLSKY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
