#! /bin/bash

PRGNAME="libunistring"

### libunistring (GNU Unicode string library)
# Библиотека, предоставляющая функции для работы со строками в формате Unicode
# a так же для работы со строками C в соответствии со стандартом Unicode

# http://www.linuxfromscratch.org/blfs/view/stable/general/libunistring.html

# Home page: http://www.gnu.org/s/libunistring
# Download:  https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.xz

# Required: no
# Optional: texlive or install-tl-unx (для пересборки документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Unicode string library)
#
# This library provides functions for manipulating Unicode strings and for
# manipulating C strings according to the Unicode standard.
#
# Home page: http://www.gnu.org/s/${PRGNAME}
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
