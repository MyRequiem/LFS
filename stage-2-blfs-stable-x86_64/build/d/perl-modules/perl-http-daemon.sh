#! /bin/bash

PRGNAME="perl-http-daemon"
ARCH_NAME="HTTP-Daemon"

### HTTP::Daemon (a simple http server class)
# HTTP::Daemon Perl модуль

# Required:    perl-http-message
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
# Package: ${PRGNAME} (a simple http server class)
#
# Instances of the HTTP::Daemon class are HTTP/1.1 servers that listen on a
# socket for incoming requests. The HTTP::Daemon is a subclass of
# IO::Socket::INET, so you can perform socket operations directly on it too.
#
# Home page: https://metacpan.org/pod/HTTP::Daemon
# Download:  https://www.cpan.org/authors/id/O/OA/OALDERS/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
