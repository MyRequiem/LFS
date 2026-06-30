#! /bin/bash

PRGNAME="p11-kit"

### p11-kit (PKCS#11 toolkit)
# Инструмент для координации работы с криптографическими модулями
# (смарт-картами, токенами) и управления сертификатами.

# Required:   no
# Recommended libtasn1
#             make-ca       (runtime)
# Optional:   gtk-doc
#             libxslt
#             nss           (runtime)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
CRON_WEEKLY="/etc/cron.weekly"
mkdir -pv "${TMP_DIR}${CRON_WEEKLY}"

# удалим строки с 20 и до конца файла
sed '20,$ d' -i trust/trust-extract-compat || exit 1

# добавим в конец файла
cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r

# Download ca-certificates needed for cURL
echo -ne "\nDownload https://curl.haxx.se/ca/cacert.pem ... "
wget -q -P /etc/ssl/certs https://curl.haxx.se/ca/cacert.pem || {
    echo "Error download cacert.pem!"
    exit 1
}
echo "Ok"
EOF

mkdir p11-build
cd p11-build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D trust_paths=/etc/pki/anchors || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# ссылка
#    /usr/bin/update-ca-certificates -> ../libexec/p11-kit/trust-extract-compat
ln -sfv "../libexec/${PRGNAME}/trust-extract-compat" \
    "${TMP_DIR}/usr/bin/update-ca-certificates"

# чтобы сделать систему прозрачной для центров сертификации при использовании
# приложений поддерживающих NSS, модуль /usr/lib/pkcs11/p11-kit-trust.so можно
# использовать как замену для /usr/lib/libnssckbi.so из пакета nss
#
# создадим ссылку /usr/lib/libnssckbi.so -> pkcs11/p11-kit-trust.so
ln -svf pkcs11/${PRGNAME}-trust.so "${TMP_DIR}/usr/lib/libnssckbi.so"

# будем периодически обновлять сертификаты (раз в неделю), настроим через fcron
UPDATE_CERTIFICATES="${CRON_WEEKLY}/update-ca-certificates.sh"
cat << EOF > "${TMP_DIR}${UPDATE_CERTIFICATES}"
#!/bin/bash

/usr/bin/update-ca-certificates
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

chmod 754 "${CRON_WEEKLY}"
chmod 754 "${UPDATE_CERTIFICATES}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PKCS#11 toolkit)
#
# It provides a standard configuration setup for installing PKCS#11 modules in
# such a way that they are discoverable. It also solves problems with
# coordinating the use of PKCS#11 by different components or libraries living
# in the same process.
#
# Home page: https://p11-glue.github.io/p11-glue/${PRGNAME}.html
# Download:  https://github.com/p11-glue/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
