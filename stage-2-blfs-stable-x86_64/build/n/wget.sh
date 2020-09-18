#! /bin/bash

PRGNAME="wget"

### Wget (a non-interactive network retriever)
# Сетевая утилита для скачивания файлов с удаленных серверов интернета по
# протоколам HTTP и FTP. Работает в не интерактивном режиме, что позволяет
# продолжать егу работу после выхода из системы.

# http://www.linuxfromscratch.org/blfs/view/stable/basicnet/wget.html

# Home page: http://www.gnu.org/software/wget/
# Download:  https://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz

# Required:    no
# Recommended: make-ca            (runtime)
# Optional:    gnutls
#              perl-http-daemon   (для тестов)
#              perl-io-socket-ssl (для тестов)
#              libidn2
#              libpsl
#              pcre или pcre2
#              valgrind           (для тестов)

ROOT="/root"
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

# известно, что HTTPS-тесты не проходят, если установлен Perl модуль
# IO::Socket::INET6
#
# Для выполнения тестов с Valgrind добавляем опцию конфигурации
# --enable-valgrind-tests
#
# make check

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a non-interactive network retriever)
#
# GNU Wget is a free network utility to retrieve files from the World Wide Web
# using HTTP and FTP, the two most widely used Internet protocols. It works
# non-interactively, thus enabling work in the background after having logged
# off.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
