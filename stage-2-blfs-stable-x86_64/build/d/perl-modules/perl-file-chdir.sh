#! /bin/bash

PRGNAME="perl-file-chdir"
ARCH_NAME="File-chdir"

### File::chdir (a more sensible way to change directories)
# File::chdir Perl модуль

# Required:    no
# Recommended: no
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
# Package: ${PRGNAME} (a more sensible way to change directories)
#
# File::chdir provides a more sensible way to change directories.
#
# Perl's chdir() has the unfortunate problem of being very, very, very global.
# If any part of your program calls chdir() or if any library you use calls
# chdir(), it changes the current working directory for the *whole* program.
# File::chdir gives you an alternative, $CWD and @CWD.
#
# Home page: https://metacpan.org/pod/File::chdir
# Download:  https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
