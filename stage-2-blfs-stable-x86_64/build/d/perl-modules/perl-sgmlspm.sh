#! /bin/bash

PRGNAME="perl-sgmlspm"
ARCH_NAME="SGMLSpm"

### SGMLSpm (Perl library for parsing the output SGMLS and NSGMLS)
# Perl-библиотека, используемая для анализа SGMLS и NSGMLS файлов

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

chmod -v 644 MYMETA.yml
perl Makefile.PL || exit 1
make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

ln -sv sgmlspl.pl "${TMP_DIR}/usr/bin/sgmlspl"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/SGMLSpm/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl library for parsing the output SGMLS and NSGMLS)
#
# The SGMLSpm module is a Perl library used for parsing the output from James
# Clark's SGMLS and NSGMLS parsers.
#
# Home page: https://metacpan.org/release/RAAB/SGMLSpm-1.1
# Download:  https://www.cpan.org/authors/id/R/RA/RAAB/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
