#! /bin/bash

PRGNAME="perl-file-copy-recursive"
ARCH_NAME="File-Copy-Recursive"

### File::Copy::Recursive (extension for recursively copying files and directories)
# File::Copy::Recursive Perl модуль

# Required:    no
# Recommended: perl-path-tiny     (для тестов)
#              perl-test-deep     (для тестов)
#              perl-test-fatal    (для тестов)
#              perl-test-file     (для тестов)
#              perl-test-warnings (для тестов)
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
# Package: ${PRGNAME} (extension for recursively copying files and directories)
#
# This module copies and moves directories recursively (or single files), to an
# optional depth and attempts to preserve each file or directory's mode
#
# Home page: https://metacpan.org/pod/File::Copy::Recursive
# Download:  https://cpan.metacpan.org/authors/id/D/DM/DMUEY/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
