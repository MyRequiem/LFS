#! /bin/bash

PRGNAME="perl-json-xs"
ARCH_NAME="JSON-XS"

### JSON::XS (JSON serialising/deserialising, done correctly and fast)
# JSON::XS Perl модуль

# Required:    perl-types-serialiser
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

yes | perl Makefile.PL || exit 1
make                   || exit 1
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
# Package: ${PRGNAME} (JSON serialising/deserialising, done correctly and fast)
#
# This module converts Perl data structures to JSON and vice versa. Its primary
# goal is to be correct and its secondary goal is to be fast. To reach the
# latter goal it was written in C.
#
# Home page: https://metacpan.org/pod/JSON::XS
# Download:  https://cpan.metacpan.org/authors/id/M/ML/MLEHMANN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
