#! /bin/bash

PRGNAME="perl-file-find-rule"
ARCH_NAME="File-Find-Rule"

### File::Find::Rule (friendlier interface to File::Find)
# Perl модуль реализующий более удобный интерфейс для File::Find

# Required:    perl-number-compare
#              perl-text-glob
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
# Package: ${PRGNAME} (friendlier interface to File::Find)
#
# File::Find::Rule is a friendlier interface to File::Find. It allows you to
# build rules which specify the desired files and directories
#
# Home page: https://metacpan.org/pod/File::Find::Rule
# Download:  https://cpan.metacpan.org/authors/id/R/RC/RCLAMP/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
