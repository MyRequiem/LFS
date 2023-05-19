#! /bin/bash

PRGNAME="libassuan"

### libassuan (Interprocess Communication Library for GPG)
# Небольшая библиотека, реализующая так называемый протокол Assuan. Этот
# протокол используется для IPC между большинством компонентов GnuPG.
# Представлена как серверная, так и клиентская часть.

# Required:    libgpg-error
# Recommended: no
# Optional:    texlive или install-tl-unx (для создания pdf и ps документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Interprocess Communication Library for GPG)
#
# This is a small library implementing the so-called Assuan protocol. This
# protocol is used for IPC between most newer GnuPG components. Both, server
# and client side functions are provided.
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
