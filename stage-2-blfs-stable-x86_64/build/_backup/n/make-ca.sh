#! /bin/bash

PRGNAME="make-ca"

### make-ca (deliver and manage a complete PKI configuration)
# Инфраструктура открытых ключей (PKI) и методы проверки их подлинности в
# ненадежных сетях.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/make-ca.html

# Home page: https://github.com/djlucas/make-ca/
# Download:  https://github.com/djlucas/make-ca/releases/download/v1.5/make-ca-1.5.tar.xz
#            http://www.cacert.org/certs/root.crt
#            http://www.cacert.org/certs/class3.crt

# Required: p11-kit (требуется во время выполнения для создания хранилищ
#               сертификатов из якорей доверия)
# Optional: java или openjdk (для создания java PKCS#12 хранилища)
#           nss (для создания общей NSSDB)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make install
make install DESTDIR="${TMP_DIR}"

install -vdm755 /etc/ssl/local
install -vdm755 "${TMP_DIR}/etc/ssl/local"

/usr/sbin/make-ca -g

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

CACERT_CLASS_1_ROOT="/etc/ssl/local/CAcert_Class_1_root.pem"
openssl x509 -in "${SOURCES}/root.crt" -text -fingerprint -setalias \
    "CAcert Class 1 root" -addtrust serverAuth -addtrust emailProtection \
    -addtrust codeSigning > "${CACERT_CLASS_1_ROOT}"
touch "${TMP_DIR}${CACERT_CLASS_1_ROOT}"

CACERT_CLASS_3_ROOT="/etc/ssl/local/CAcert_Class_3_root.pem"
openssl x509 -in "${SOURCES}/class3.crt" -text -fingerprint -setalias \
    "CAcert Class 3 root" -addtrust serverAuth -addtrust emailProtection \
    -addtrust codeSigning > "${CACERT_CLASS_3_ROOT}"
touch "${TMP_DIR}${CACERT_CLASS_3_ROOT}"

/usr/sbin/make-ca -r -f

cp -vR /etc/pki "${TMP_DIR}/etc"

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
