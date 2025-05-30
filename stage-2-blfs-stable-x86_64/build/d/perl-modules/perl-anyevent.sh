#! /bin/bash

PRGNAME="perl-anyevent"
ARCH_NAME="AnyEvent"

### AnyEvent (the DBI of event loop programming)
# AnyEvent Perl модуль

# Required:    perl-canary-stability
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
# Package: ${PRGNAME} (the DBI of event loop programming)
#
# AnyEvent provides a uniform interface to various event loops. This allows
# module authors to use event loop functionality without forcing module users
# to use a specific event loop implementation (since more than one event loop
# cannot coexist peacefully).
#
# Home page: https://metacpan.org/pod/${ARCH_NAME}
# Download:  https://cpan.metacpan.org/authors/id/M/ML/MLEHMANN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
