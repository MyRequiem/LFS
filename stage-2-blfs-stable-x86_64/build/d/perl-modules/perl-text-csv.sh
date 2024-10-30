#! /bin/bash

PRGNAME="perl-text-csv"
ARCH_NAME="Text-CSV"

### Text::CSV (comma-separated values manipulator)
# Text::CSV Perl модуль

# Required:    no
# Recommended: perl-text-csv-xs (требуется для сборки пакета biber)
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
# Package: ${PRGNAME} (comma-separated values manipulator)
#
# Text::CSV is a comma-separated values manipulator, using XS (eXternal
# Subroutine - for subroutines written in C or C++) or pure perl
#
# Home page: https://metacpan.org/pod/Text::CSV
# Download:  https://www.cpan.org/authors/id/I/IS/ISHIGAKI/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
