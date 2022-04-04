#! /bin/bash

PRGNAME="perl-try-tiny"
ARCH_NAME="Try-Tiny"

### Try::Tiny (Try::Tiny Perl module)
# Try::Tiny Perl модуль

# Required:    no
# Recommended: no
# Optional:    perl-capture-tiny (для тестов)

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
# Package: ${PRGNAME} (Try::Tiny Perl module)
#
# Try::Tiny provides try and catch to expect and handle exceptional conditions,
# avoiding quirks in Perl and common mistakes
#
# Home page: https://metacpan.org/pod/Try::Tiny
# Download:  https://cpan.metacpan.org/authors/id/E/ET/ETHER/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
