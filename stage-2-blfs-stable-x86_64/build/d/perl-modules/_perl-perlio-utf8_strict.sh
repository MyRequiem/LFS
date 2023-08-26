#! /bin/bash

PRGNAME="perl-perlio-utf8_strict"
ARCH_NAME="PerlIO-utf8_strict"

### PerlIO::utf8_strict (fast and correct UTF-8 IO)
# PerlIO::utf8_strict Perl модуль

# Required:    no
# Recommended: perl-test-exception (для тестов)
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
# Package: ${PRGNAME} (fast and correct UTF-8 IO)
#
# PerlIO::utf8_strict provides a fast and correct UTF-8 PerlIO layer. Unlike
# perl's default :utf8 layer it checks the input for correctness
#
# Home page: https://metacpan.org/pod/PerlIO::utf8_strict
# Download:  https://www.cpan.org/authors/id/L/LE/LEONT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
