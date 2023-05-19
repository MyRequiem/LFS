#! /bin/bash

PRGNAME="libgcrypt"

### libgcrypt (General purpose crypto library)
# Криптобиблиотека общего назначения, основанная на коде, используемом в GnuPG.
# Библиотека предоставляет интерфейс высокого уровня для криптографии с
# использованием расширяемого и гибкого API

# Required:    libgpg-error
# Recommended: no
# Optional:    pth
#              texlive или install-tl-unx (для создания pdf и ps документации)

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
