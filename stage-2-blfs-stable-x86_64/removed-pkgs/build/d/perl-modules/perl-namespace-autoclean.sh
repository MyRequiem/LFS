#! /bin/bash

PRGNAME="perl-namespace-autoclean"
ARCH_NAME="namespace-autoclean"

### namespace::autoclean (keep imports out of your namespace)
# namespace::autoclean Perl модуль

# Required:    perl-namespace-clean
#              perl-sub-identify
# Recommended: perl-test-needs (для тестов)
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
# Package: ${PRGNAME} (keep imports out of your namespace)
#
# This module is very similar to namespace::clean, except it will clean all
# imported functions, no matter if you imported them before or after you used
# the pragma. It will also not touch anything that looks like a method.
#
# Home page: https://metacpan.org/pod/namespace::autoclean
# Download:  https://cpan.metacpan.org/authors/id/E/ET/ETHER/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
