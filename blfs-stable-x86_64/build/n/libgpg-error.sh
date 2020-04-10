#! /bin/bash

PRGNAME="libgpg-error"

### libgpg-error
# Библиотека, которая определяет общие значения ошибок для всех компонентов
# GnuPG. Среди них GPG, GPGSM, GPGME, GPG-Agent, libgcrypt, Libksba, DirMngr,
# Pinentry, SmartCard Daemon и многое другое.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libgpg-error.html

# Home page: https://www.gnupg.org/related_software/libgpg-error/index.en.html
# Download:  https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.36.tar.bz2

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}${DOCS}"

# разрешим сборку с gawk-5.0
sed -i 's/namespace/pkg_&/' src/Makefile.{am,in} src/mkstrtable.awk

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

install -v -m644 -D README "${DOCS}/README"
install -v -m644 -D README "${TMP_DIR}${DOCS}/README"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GnuPG Error Definitions Library)
#
# This is a library that defines common error values for all GnuPG components.
# Among these are GPG, GPGSM, GPGME, GPG-Agent, libgcrypt, Libksba, DirMngr,
# Pinentry, SmartCard Daemon, and more.
#
# Home page: https://www.gnupg.org/related_software/libgpg-error/index.en.html
# Download:  https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.36.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
