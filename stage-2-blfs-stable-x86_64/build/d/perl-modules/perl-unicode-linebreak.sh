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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Unicode/LineBreak/.packlist"

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