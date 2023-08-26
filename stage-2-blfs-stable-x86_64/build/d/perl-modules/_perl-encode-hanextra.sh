#! /bin/bash

PRGNAME="perl-encode-hanextra"
ARCH_NAME="Encode-HanExtra"

### Encode::HanExtra (extra sets of Chinese encodings)
# Encode::HanExtra Perl модуль

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PERL_USE_UNSAFE_INC=1 perl Makefile.PL || exit 1
make                                   || exit 1
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
# Package: ${PRGNAME} (extra sets of Chinese encodings)
#
# The Encode::HanExtra module provides extra sets of Chinese Encodings which
# are not included in the core Encode module because of size issues
#
# Home page: https://metacpan.org/pod/Encode::HanExtra
# Download:  https://www.cpan.org/authors/id/A/AU/AUDREYT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
