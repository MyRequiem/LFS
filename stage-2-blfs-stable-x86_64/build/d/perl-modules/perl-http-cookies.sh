#! /bin/bash

PRGNAME="perl-http-cookies"
ARCH_NAME="HTTP-Cookies"

### HTTP::Cookies (HTTP cookie jars)
# HTTP::Cookies Perl модуль

# Required:    perl-http-message
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
# Package: ${PRGNAME} (HTTP cookie jars)
#
# HTTP::Cookies provides a class for objects that represent a "cookie jar" -
# that is, a database of all the HTTP cookies that a given LWP::UserAgent
# (from perl-libwww-perl package) object knows about
#
# Home page: https://metacpan.org/pod/HTTP::Cookies
# Download:  https://cpan.metacpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
