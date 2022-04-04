#! /bin/bash

PRGNAME="perl-number-compare"
ARCH_NAME="Number-Compare"

### Number::Compare (Number::Compare perl module)
# Perl модуль для сравнения передаваемого числа с K, ki, m, mi, g, gi

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

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Number::Compare perl module)
#
# Number::Compare compiles a simple comparison to an anonymous subroutine,
# which you can call with a value to be tested against. It understands IEC
# standard magnitudes (k, ki, m, mi, g, gi)
#
# Home page: https://metacpan.org/pod/Number::Compare
# Download:  https://cpan.metacpan.org/authors/id/R/RC/RCLAMP/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
