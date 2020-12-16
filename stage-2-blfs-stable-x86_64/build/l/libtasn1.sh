#! /bin/bash

PRGNAME="libtasn1"

### libtasn1 (ASN.1 library)
# C-библиотека для кодирования и декодирования данных DER/BER в
# телекоммуникационных и компьютерных сетях следуя схеме ASN.1

# Required:    no
# Recommended: no
# Optional:    gtk-doc
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--disable-valgrind-tests"
GTK_DOC="--disable-gtk-doc"

command -v valgrind     &>/dev/null && VALGRIND="--enable-valgrind-tests"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    "${VALGRIND}" \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим документацию
[[  "x${GTK_DOC}" == "x--enable-gtk-doc" ]] && \
    make -C doc/reference install-data-local DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
