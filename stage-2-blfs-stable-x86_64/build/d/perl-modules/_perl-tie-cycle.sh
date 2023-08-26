#! /bin/bash

PRGNAME="perl-tie-cycle"
ARCH_NAME="Tie-Cycle"

### Tie::Cycle (Tie::Cycle to go through a list over and over again)
# Perl модуль реализующий циклический просмотр списков

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
# Package: ${PRGNAME} (Tie::Cycle to go through a list over and over again)
#
# You use Tie::Cycle to go through a list over and over again. Once you get to
# the end of the list, you go back to the beginning. You dont have to worry
# about any of this since the magic of tie does that for you.
#
# Home page: https://metacpan.org/pod/Tie::Cycle
# Download:  https://cpan.metacpan.org/authors/id/B/BD/BDFOY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
