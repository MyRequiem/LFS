#! /bin/bash

PRGNAME="openssl"

### OpenSSl
# Содержит криптографические библиотеки и инструменты управления для
# предоставления криптографических функций другим пакетам, таким как OpenSSH,
# почтовым приложениям, веб-браузерам (для доступа по протоколу HTTPS) и т.д.

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/openssl.html

# Home page: https://www.openssl.org/
# Download:  https://www.openssl.org/source/openssl-1.1.1f.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./config                  \
    --prefix=/usr         \
    --openssldir=/etc/ssl \
    --libdir=lib          \
    shared                \
    zlib-dynamic || exit 1

make || exit 1
# запускаем тесты. Известно, что один подтест в тесте 20-test_enc.t не проходит
make test

# устанавливаем пакет
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
make MANSUFFIX=ssl install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mv -v /usr/share/doc/${PRGNAME} "${DOCS}"
cp -vfr doc/* "${DOCS}"

mv -v "${TMP_DIR}/usr/share/doc/${PRGNAME}" "${TMP_DIR}${DOCS}"
cp -vfr doc/* "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Secure Sockets Layer toolkit)
#
# The OpenSSL certificate management tool and the shared libraries that provide
# various encryption and decryption algorithms and protocols. These are useful
# for providing cryptographic functions to other packages, such as OpenSSH,
# email applications and web browsers (for accessing HTTPS sites).
#
# Home page: https://www.openssl.org/
# Download:  https://www.openssl.org/source/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
