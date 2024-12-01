#! /bin/bash

PRGNAME="gnupg"

### GnuPG (The GNU Privacy Guard)
# Программа для шифрования информации, создания электронных цифровых подписей и
# управления ключами шифрования.

# Required:    libassuan
#              libgcrypt
#              libksba
#              npth
# Recommended: gnutls
#              pinentry
# Optional:    curl
#              fuse3
#              imagemagick  (для создания документации)
#              libusb
#              MTA          (dovecot или exim или postfix или sendmail)
#              openldap
#              sqlite
#              texlive или install-tl-unx
#              fig2dev     (для создания документации) http://mcj.sourceforge.net/
#              adns        (http://www.chiark.greenend.org.uk/~ian/adns/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd    build || exit 1

# создаем утилитy g13
#    --enable-g13
../configure             \
    --prefix=/usr        \
    --localstatedir=/var \
    --sysconfdir=/etc    \
    --enable-g13         \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The GNU Privacy Guard)
#
# GnuPG is GNU's tool for secure communication and data storage. It can be used
# to encrypt data and to create digital signatures. It includes an advanced key
# management facility and is compliant with the proposed OpenPGP Internet
# standard as described in RFC2440 and the S/MIME standard as described by
# several RFCs.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
