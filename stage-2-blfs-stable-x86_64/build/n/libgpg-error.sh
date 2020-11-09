#! /bin/bash

PRGNAME="libgpg-error"

### libgpg-error (GnuPG Error Definitions Library)
# Библиотека, которая определяет общие значения ошибок для всех компонентов
# GnuPG. Среди них GPG, GPGSM, GPGME, GPG-Agent, libgcrypt, Libksba, DirMngr,
# Pinentry, SmartCard Daemon и многое другое.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# документация
install -v -m644 README "${TMP_DIR}${DOCS}/README"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GnuPG Error Definitions Library)
#
# This is a library that defines common error values for all GnuPG components.
# Among these are GPG, GPGSM, GPGME, GPG-Agent, libgcrypt, Libksba, DirMngr,
# Pinentry, SmartCard Daemon, and more.
#
# Home page: https://www.gnupg.org/related_software/${PRGNAME}/index.en.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
