#! /bin/bash

PRGNAME="wget"

### Wget (a non-interactive network retriever)
# Мощная консольная утилита для скачивания файлов из интернета по протоколам
# HTTP, HTTPS и FTP.

# Required:    no
# Recommended: libpsl
#              make-ca            (runtime)
# Optional:    gnutls
#              perl-http-daemon   (для тестов)
#              perl-io-socket-ssl (для тестов)
#              libidn2
#              libproxy
#              valgrind           (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# wget бует использовать OpenSSL вместо GnuTLS
#    --with-ssl=openssl
./configure            \
    --prefix=/usr      \
    --sysconfdir=/etc  \
    --with-ssl=openssl || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a non-interactive network retriever)
#
# GNU Wget is a free network utility to retrieve files from the World Wide Web
# using HTTP and FTP, the two most widely used Internet protocols. It works
# non-interactively, thus enabling work in the background after having logged
# off.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
