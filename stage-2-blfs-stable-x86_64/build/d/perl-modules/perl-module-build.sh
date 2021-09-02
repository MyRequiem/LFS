#! /bin/bash

PRGNAME="perl-module-build"
ARCH_NAME="Module-Build"

### Module::Build (Perl module for build and install perl Modules)
# Модуль позволяет создавать модули Perl без использования команды make

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
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Module/Build/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl module for build and install perl Modules)
#
# Module::Build is a system for building, testing, and installing Perl modules.
# It is meant to be an alternative to ExtUtils::MakeMaker. Developers may alter
# the behavior of the module through subclassing. It also does not require a
# make on your system - most of the Module::Build code is pure-perl and written
# in a very cross-platform way.
#
# Home page: https://metacpan.org/pod/Module::Build
# Download:  https://cpan.metacpan.org/authors/id/L/LE/LEONT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
