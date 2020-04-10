#! /bin/bash

PRGNAME="make-ca"

### make-ca
# Инфраструктура открытых ключей (PKI) и методы проверки их подлинности в
# ненадежных сетях.

# http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/make-ca.html

# Home page: https://github.com/djlucas/make-ca/
# Download:  https://github.com/djlucas/make-ca/releases/download/v1.4/make-ca-1.4.tar.xz

# Required: p11-kit (требуется во время выполнения для создания хранилищ
#               сертификатов из якорей доверия)
# Optional: java или openjdk (для создания java PKCS#12 хранилища)
#           nss (для создания общей NSSDB)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

make install
make install DESTDIR="${TMP_DIR}"
install -vdm755 /etc/ssl/local
install -vdm755 "${TMP_DIR}/etc/ssl/local"

/usr/sbin/make-ca -g

ln -svf /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/ca-bundle.crt
(
    cd "${TMP_DIR}/etc/ssl" || exit 1
    ln -svf ../pki/tls/certs/ca-bundle.crt ca-bundle.crt
)

install -vdm755 /etc/cron.weekly
install -vdm755 "${TMP_DIR}/etc/cron.weekly"

cat > /etc/cron.weekly/update-pki.sh << "EOF"
#!/bin/bash
/usr/sbin/make-ca -g
EOF
chmod 754 /etc/cron.weekly/update-pki.sh

cat > "${TMP_DIR}/etc/cron.weekly/update-pki.sh" << "EOF"
#!/bin/bash
/usr/sbin/make-ca -g
EOF
chmod 754 "${TMP_DIR}/etc/cron.weekly/update-pki.sh"

wget http://www.cacert.org/certs/root.crt
wget http://www.cacert.org/certs/class3.crt

openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
    -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning > \
    /etc/ssl/local/CAcert_Class_1_root.pem
touch "${TMP_DIR}/etc/ssl/local/CAcert_Class_1_root.pem"

openssl x509 -in class3.crt -text -fingerprint -setalias "CAcert Class 3 root" \
    -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning > \
    /etc/ssl/local/CAcert_Class_3_root.pem
touch "${TMP_DIR}/etc/ssl/local/CAcert_Class_3_root.pem"

/usr/sbin/make-ca -r -f

openssl x509 -in /etc/ssl/certs/Makebelieve_CA_Root.pem \
    -text \
    -fingerprint \
    -setalias "Disabled Makebelieve CA Root" \
    -addreject serverAuth \
    -addreject emailProtection \
    -addreject codeSigning > /etc/ssl/local/Disabled_Makebelieve_CA_Root.pem
touch "${TMP_DIR}/etc/ssl/local/Disabled_Makebelieve_CA_Root.pem"

/usr/sbin/make-ca -r -f

cp -R /etc/pki "${TMP_DIR}/etc"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (deliver and manage a complete PKI configuration)
#
# make-ca is a utility to deliver and manage a complete PKI configuration for
# workstaitons and servers using only standard Unix utilities, OpenSSL, and
# p11-kit, using a Mozilla cacerts.txt or like file as the trust source. It can
# optionally generate keystores for OpenJDK PKCS#12 and NSS if installed. It
# was originally developed for use with Linux From Scratch to minimize
# dependencies for early system build, but has been written to be generic
# enough for any Linux distribution.
#
# Home page: https://github.com/djlucas/make-ca/
# Download:  https://github.com/djlucas/make-ca/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
