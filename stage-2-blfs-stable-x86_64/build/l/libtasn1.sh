#! /bin/bash

PRGNAME="libtasn1"

### libtasn1 (ASN.1 library)
# Библиотека для работы со структурами данных ASN.1, которые повсеместно
# используются в криптографии и сетевых протоколах.

# Required:    no
# Recommended: no
# Optional:    gtk-doc
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

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
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
