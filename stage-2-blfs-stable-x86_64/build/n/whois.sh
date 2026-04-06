#! /bin/bash

PRGNAME="whois"

### Whois (whois directory client)
# Клиент для получения информации о владельцах доменных имен и IP-адресов.

# Required:    no
# Recommended: no
# Optional:    libidn или libidn2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1

# whois и mkpasswd
make prefix=/usr install-whois    BASEDIR="${TMP_DIR}"
make prefix=/usr install-mkpasswd BASEDIR="${TMP_DIR}"
# файлы локали
make prefix=/usr install-pos      BASEDIR="${TMP_DIR}"

# утилита mkpasswd уже была установлена в LFS с пакетом expect, удалим ее
rm -f /usr/bin/mkpasswd /usr/share/man/man1/mkpasswd.1
sed '/mkpasswd/d' -i /var/log/packages/expect-*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (whois directory client)
#
# Whois is a client-side application which queries the whois directory service
# for information pertaining to a particular domain name.
#
# Home page: https://www.linux.it/~md/software/
# Download:  https://github.com/rfc1036/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
