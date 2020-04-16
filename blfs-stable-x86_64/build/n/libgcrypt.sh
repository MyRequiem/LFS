#! /bin/bash

PRGNAME="libgcrypt"

### libgcrypt (General purpose crypto library)
# Криптобиблиотека общего назначения, основанная на коде, используемом в GnuPG.
# Библиотека предоставляет интерфейс высокого уровня для криптографии с
# использованием расширяемого и гибкого API

# http://www.linuxfromscratch.org/blfs/view/stable/general/libgcrypt.html

# Home page: https://gnupg.org/software/libgcrypt/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.5.tar.bz2

# Required: libgpg-error
# Optional: pth
#           texlive или install-tl-unx (для создания pdf и ps документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

./configure \
    --prefix=/usr || exit 1

make || exit 1

# собираем документацию в формате html и plaintext
make -C doc html
makeinfo --html --no-split -o doc/gcrypt_nochunks.html doc/gcrypt.texi
makeinfo --plaintext       -o doc/gcrypt.txt           doc/gcrypt.texi

# если в системе установлен пакет texlive или install-tl-unx, то можно собрать
# документацию в формате pdf и ps
# make -C doc pdf ps

# make check

make install
make install DESTDIR="${TMP_DIR}"

install -v -dm755   "${DOCS}/html"
install -v -m644 doc/gcrypt.html/* "${DOCS}/html"
install -v -m644 doc/gcrypt.html/* "${TMP_DIR}${DOCS}/html"

install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} "${DOCS}"
install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} \
    "${TMP_DIR}${DOCS}"

install -v -m644 doc/gcrypt_nochunks.html "${DOCS}"
install -v -m644 doc/gcrypt_nochunks.html "${TMP_DIR}${DOCS}"

install -v -m644 doc/gcrypt.{txt,texi} "${DOCS}"
install -v -m644 doc/gcrypt.{txt,texi} "${TMP_DIR}${DOCS}"

# если мы собирали документацию в pdf и ps форматах
# install -v -m644 doc/gcrypt.{pdf,ps,dvi} "${DOCS}"
# install -v -m644 doc/gcrypt.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (General purpose crypto library)
#
# The libgcrypt package contains a general purpose crypto library based on the
# code used in GnuPG. The library provides a high level interface to
# cryptographic building blocks using an extendable and flexible API.
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
