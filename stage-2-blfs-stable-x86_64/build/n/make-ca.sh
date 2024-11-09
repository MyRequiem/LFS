#! /bin/bash

PRGNAME="make-ca"

### make-ca (deliver and manage a complete PKI configuration)
# Инфраструктура открытых ключей (PKI) и методы проверки их подлинности в
# ненадежных сетях.

# Required:    p11-kit (собранный с уже установленным libtasn1)
# Recommended: no
# Optional:    nss

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/"{ssl/local,cron.weekly}

make install DESTDIR="${TMP_DIR}"

# скрипт 'make-ca' загрузит в /etc/ssl/ файл certdata.txt, затем загрузит в
# /etc/pki/ и обработает сертификаты включенные в него, для использования в
# качестве якорей доверия модуля p11-kit
# "${TMP_DIR}/usr/sbin/make-ca" --get --destdir "${TMP_DIR}"
#    --get    - загрузить файл certdata.txt
#
# чтобы не использовать утилиту make-ca при установке пакета, мы сразу скачали
# файл certdata.txt в директорию исходников: /root/src/lfs/src/certdata.txt
cp "${SOURCES}/certdata.txt" "${TMP_DIR}/etc/ssl/" || exit 1

# копируем /etc/make-ca/make-ca.conf.dist в make-ca.conf
cp "${TMP_DIR}/etc/${PRGNAME}/${PRGNAME}.conf"{.dist,} || exit 1

UPDATE_PKI="/etc/cron.weekly/update-pki.sh"
cat << EOF > "${TMP_DIR}${UPDATE_PKI}"
#!/bin/bash

/usr/sbin/make-ca -g
EOF
chmod 754 "${TMP_DIR}${UPDATE_PKI}"

### добавим дополнительные CA Certificates в /etc/ssl/local
openssl x509 -in "${SOURCES}/root.crt" \
    -text                              \
    -fingerprint                       \
    -setalias "CAcert Class 1 root"    \
    -addtrust serverAuth               \
    -addtrust emailProtection          \
    -addtrust codeSigning > "${TMP_DIR}/etc/ssl/local/CAcert_Class_1_root.pem"

openssl x509 -in "${SOURCES}/class3.crt" \
    -text                                \
    -fingerprint                         \
    -setalias "CAcert Class 3 root"      \
    -addtrust serverAuth                 \
    -addtrust emailProtection            \
    -addtrust codeSigning > "${TMP_DIR}/etc/ssl/local/CAcert_Class_3_root.pem"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: https://github.com/djlucas/${PRGNAME}/
# Download:  https://github.com/lfs-book/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
