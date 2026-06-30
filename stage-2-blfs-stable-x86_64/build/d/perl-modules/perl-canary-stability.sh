#! /bin/bash

PRGNAME="perl-canary-stability"
ARCH_NAME="Canary-Stability"

### Canary::Stability (Canary::Stability perl module)
# Служебный инструмент, который проверяет стабильность текущей версии Perl
# перед установкой сложных модулей. Он работает как «канарейка в шахте»,
# предупреждая о возможных проблемах совместимости.

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \+

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Canary::Stability perl module)
#
# canary to check perl compatibility for schmorp's modules
#
# Home page: https://metacpan.org/pod/Canary::Stability
# Download:  https://cpan.metacpan.org/authors/id/M/ML/MLEHMANN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
