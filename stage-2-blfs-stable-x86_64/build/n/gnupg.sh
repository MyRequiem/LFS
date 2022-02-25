#! /bin/bash

PRGNAME="gnupg"

### GnuPG (The GNU Privacy Guard)
# Программа для шифрования информации, создания электронных цифровых подписей и
# управления ключами шифрования.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/gnupg.html

# Home page: https://gnupg.org/
# Download:  https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.19.tar.bz2

# Required:    libassuan
#              libgcrypt
#              libksba
#              npth
# Recommended: pinentry
# Optional:    curl
#              fuse
#              gnutls
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
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# по умолчанию GnuPG не устанавливает устаревший скрипт gpg-zip, но он все еще
# необходимо для некоторых программ, поэтому включим его установку
sed -e '/noinst_SCRIPTS = gpg-zip/c sbin_SCRIPTS += gpg-zip' \
    -i tools/Makefile.in || exit 1

# создаем утилитy g13
#    --enable-g13
./configure                  \
    --prefix=/usr            \
    --enable-g13             \
    --localstatedir=/var     \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# документация
# makeinfo --html --no-split -o doc/gnupg_nochunks.html doc/gnupg.texi || exit 1
makeinfo --plaintext -o doc/gnupg.txt doc/gnupg.texi || exit 1

# html-документация
# make -C doc html || exit 1

# если пакет texlive установлен, то можно создать документацию в pdf и ps
# форматах
PDF_DOCS=""
# command -v texdoc &>/dev/null && PDF_DOCS="true"
if [ -n "${PDF_DOCS}" ]; then
    make -C doc pdf ps || exit 1
fi

# make check

make install DESTDIR="${TMP_DIR}"

# установка документации
install -v -m644 doc/gnupg.txt "${TMP_DIR}${DOCS}"
# install -v -m644 doc/gnupg_nochunks.html  "${TMP_DIR}${DOCS}/html/gnupg.html"
# install -v -m644 doc/gnupg.html/*         "${TMP_DIR}${DOCS}/html"

mv "${TMP_DIR}${DOCS}/examples/gpgconf.conf" \
    "${TMP_DIR}${DOCS}/gpgconf.conf_example"
rm -rf "${TMP_DIR}${DOCS}/examples"

# если создавали документацию в форматах pdf и ps
if [ -n "${PDF_DOCS}" ]; then
    install -v -m644 doc/gnupg.{pdf,dvi,ps} "${TMP_DIR}${DOCS}"
fi

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
# Home page: https://gnupg.org/
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
