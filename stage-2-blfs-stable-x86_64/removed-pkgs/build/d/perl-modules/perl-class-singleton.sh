#! /bin/bash

PRGNAME="perl-class-singleton"
ARCH_NAME="Class-Singleton"

### Class::Singleton (implementation of a "Singleton" Perl class)
# Class::Singleton Perl модуль

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
# Package: ${PRGNAME} (implementation of a "Singleton" Perl class)
#
# A Singleton describes an object class that can have only one instance in any
# system, such as a print spooler. This module implements a Singelton class
# from which other classes can be derived.
#
# Home page: https://metacpan.org/pod/Class::Singleton
# Download:  https://cpan.metacpan.org/authors/id/S/SH/SHAY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
