#! /bin/bash

PRGNAME="perl-alien-libxml2"
ARCH_NAME="Alien-Libxml2"

### Alien::Libxml2 (install the C libxml2 library on your system)
# Alien::Libxml2 Perl модуль

# Required:    alien-build-plugin-download-gitlab
#              libxml2
#              perl-path-tiny
# Recommended: perl-test2-suite (для тестов)
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
# Package: ${PRGNAME} (install the C libxml2 library on your system)
#
# Alien::Libxml2 is designed to allow modules to install the C libxml2 library
# on your system. In BLFS, it uses pkg-config to find how to link to the
# installed libxml2
#
# Home page: https://metacpan.org/pod/Alien::Libxml2
# Download:  https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
