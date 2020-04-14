#! /bin/bash

PRGNAME="libtasn1"

### libtasn1
# Легко переносимая библиотека C, которая кодирует и декодирует данные DER/BER
# в телекоммуникациях и компьютерных сетях следуя схеме ASN.1

# http://www.linuxfromscratch.org/blfs/view/stable/general/libtasn1.html

# Home page: http://www.gnu.org/software/libtasn1/
# Download:  https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.16.0.tar.gz

# Required: no
# Optional: gtk-doc
#           valgrind

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

# установим документацию
make -C doc/reference install-data-local
make -C doc/reference install-data-local DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ASN.1 library)
#
# Libtasn1 is the GNU ASN.1 library. Abstract Syntax Notation One (ASN.1) is a
# standard and flexible notation that describes rules and structures for
# representing, encoding, transmitting, and decoding data in telecommunications
# and computer networking.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
