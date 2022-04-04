#! /bin/bash

PRGNAME="perl-file-sharedir"
ARCH_NAME="File-ShareDir"

### File::ShareDir (locate per-dist and per-module shared files)
# File::ShareDir Perl модуль

# Required:    perl-class-inspector
#              perl-file-sharedir-install
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
# Package: ${PRGNAME} (locate per-dist and per-module shared files)
#
# File::ShareDir allows you to access data files which have been installed by
# File::ShareDir::Install
#
# Home page: https://metacpan.org/pod/File::ShareDir
# Download:  https://cpan.metacpan.org/authors/id/R/RE/REHSACK/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
