#! /bin/bash

PRGNAME="perl-eval-closure"
ARCH_NAME="Eval-Closure"

### Eval::Closure (safely and cleanly create closures via string eval)
# Eval::Closure Perl модуль

# Required:    no
# Recommended: --- для тестов ---
#              perl-test-fatal
#              perl-test-requires
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
# Package: ${PRGNAME} (safely and cleanly create closures via string eval)
#
# Eval::Closure safely and cleanly creates closures via string eval
#
# Home page: https://metacpan.org/pod/Eval::Closure
# Download:  https://cpan.metacpan.org/authors/id/D/DO/DOY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
