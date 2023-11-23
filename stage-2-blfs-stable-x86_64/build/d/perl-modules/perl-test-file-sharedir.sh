#! /bin/bash

PRGNAME="perl-test-file-sharedir"
ARCH_NAME="Test-File-ShareDir"

### Test::File::ShareDir (create a fake sharedir for your modules for testing)
# Test::File::ShareDir Perl модуль

# Required:    perl-class-tiny
#              perl-file-copy-recursive
#              perl-file-sharedir
#              perl-path-tiny
#              perl-scope-guard
# Recommended: perl-test-fatal (для тестов)
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
# Package: ${PRGNAME} (create a fake sharedir for your modules for testing)
#
# Test::File::ShareDir is some low level plumbing to enable a distribution to
# perform tests while consuming its own share directories in a manner similar
# to how they will be once installed. This allows File-ShareDir to see the
# latest version of content instead of whatever is installed on the target
# system where you are testing.
#
# Home page: https://metacpan.org/pod/Test::File::ShareDir
# Download:  https://cpan.metacpan.org/authors/id/K/KE/KENTNL/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
