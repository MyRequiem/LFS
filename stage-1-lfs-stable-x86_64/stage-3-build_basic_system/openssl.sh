#! /bin/bash

PRGNAME="openssl"

### OpenSSl (Secure Sockets Layer toolkit)
# Содержит криптографические библиотеки и инструменты управления для
# предоставления криптографических функций другим пакетам, таким как OpenSSH,
# почтовым приложениям, веб-браузерам (для доступа по протоколу HTTPS) и т.д.

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

make || make -j1 || exit 1

# известно, что один тест 30-test_afalg.t is не проходит в определенных
# конфигурациях ядра (предполагается, что не были выбраны некоторые параметры
# шифрования)
# make test

# устанавливаем пакет
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile || exit 1
make MANSUFFIX=ssl install DESTDIR="${TMP_DIR}"

# переименуем директорию с документацией
mv -v "${TMP_DIR}/usr/share/doc/${PRGNAME}" \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
