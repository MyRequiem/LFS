#! /bin/bash

PRGNAME="p11-kit"

### p11-kit
# Пакет p11-kit предоставляет способ загрузки и перечисления PKCS#11 (Модулей
# криптографического интерфейса Token Standard)

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/p11-kit.html

# Home page: http://p11-glue.freedesktop.org/p11-kit.html
# Download:  https://github.com/p11-glue/p11-kit/releases/download/0.23.20/p11-kit-0.23.20.tar.xz

# Required:   no
# Recommended libtasn1
#             make-ca
# Optional:   gtk-doc
#             libxslt
#             nss (runtime)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sed '20,$ d' -i trust/trust-extract-compat.in || exit 1

cat >> trust/trust-extract-compat.in << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Generate a new trust store
/usr/sbin/make-ca -f -g
EOF

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --with-trust-paths=/etc/pki/anchors || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

ln -svf /usr/libexec/p11-kit/trust-extract-compat \
    /usr/bin/update-ca-certificates
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv ../libexec/p11-kit/trust-extract-compat update-ca-certificates
)

ln -svf ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf ./pkcs11/p11-kit-trust.so libnssckbi.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (PKCS#11 toolkit)
#
# It provides a standard configuration setup for installing PKCS#11 modules in
# such a way that they are discoverable. It also solves problems with
# coordinating the use of PKCS#11 by different components or libraries living
# in the same process.
#
# Home page: http://p11-glue.freedesktop.org/p11-kit.html
# Download:  https://github.com/p11-glue/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
