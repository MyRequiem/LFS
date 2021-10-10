#! /bin/bash

PRGNAME="perl-mro-compat"
ARCH_NAME="MRO-Compat"

### MRO::Compat (mro::* interface compatibility for Perls < 5.9.5)
# MRO::Compat Perl модуль

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

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/MRO/Compat/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mro::* interface compatibility for Perls < 5.9.5)
#
# The "mro" namespace provides several utilities for dealing with method
# resolution order and method caching in general in Perl 5.9.5 and higher. This
# module provides those interfaces for earlier versions of Perl.
#
# Home page: https://metacpan.org/pod/MRO::Compat
# Download:  https://cpan.metacpan.org/authors/id/H/HA/HAARG/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
