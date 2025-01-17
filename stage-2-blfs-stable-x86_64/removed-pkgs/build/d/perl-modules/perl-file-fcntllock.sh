#! /bin/bash

PRGNAME="perl-file-fcntllock"
ARCH_NAME="File-FcntlLock"

### File::FcntlLock (file locking with fcntl)
# File::FcntlLock Perl модуль

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
# Package: ${PRGNAME} (file locking with fcntl)
#
# File locking in Perl is usually done using the flock function. Unfortunately,
# this only allows locks on whole files and is often implemented in terms of
# the flock system function which has some shortcomings and slightly different
# behaviour than fcntl. Using this module file locking via fcntl(2) can be done
#
# Home page: https://metacpan.org/pod/File::FcntlLock
# Download:  https://www.cpan.org/authors/id/J/JT/JTT/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
