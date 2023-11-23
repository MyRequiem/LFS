#! /bin/bash

PRGNAME="perl-text-csv-xs"
ARCH_NAME="Text-CSV_XS"

### Text::CSV_XS (comma-separated values manipulation routines)
# Text::CSV_XS Perl модуль

# Required:    no
# Recommended: no
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
# Package: ${PRGNAME} (comma-separated values manipulation routines)
#
# Text::CSV_XS provides facilities for the composition and decomposition of
# comma-separated values
#
# Home page: https://metacpan.org/pod/Text::CSV_XS
# Download:  https://cpan.metacpan.org/authors/id/H/HM/HMBRAND/${ARCH_NAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
