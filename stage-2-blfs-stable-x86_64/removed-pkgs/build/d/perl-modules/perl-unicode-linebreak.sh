#! /bin/bash

PRGNAME="perl-unicode-linebreak"
ARCH_NAME="Unicode-LineBreak"

### Unicode::LineBreak (UAX #14 Unicode Line Breaking Algorithm)
# Unicode::LineBreak Perl модуль

# Required:    perl-mime-charset
#              wget    (для скачивания двух файлов во время тестов)
# Recommended: no
# Optional:    libthai (https://linux.thai.net/projects/libthai/)

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
# Package: ${PRGNAME} (UAX #14 Unicode Line Breaking Algorithm)
#
# Unicode::LineBreak provides a UAX #14 Unicode Line Breaking Algorithm
#
# Home page: https://metacpan.org/dist/Unicode-LineBreak/view/lib/Unicode/LineBreak.pod
# Download:  https://www.cpan.org/authors/id/N/NE/NEZUMI/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
