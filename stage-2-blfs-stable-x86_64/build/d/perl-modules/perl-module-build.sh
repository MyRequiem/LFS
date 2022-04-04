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

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

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
