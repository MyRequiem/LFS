#! /bin/bash

PRGNAME="libidn2"

### libidn2 (GNU Internationalized Domain Name library version 2)
# Библиотека для поддержки интернациональных доменных имен, позволяющая
# использовать в адресах сайтов символы национальных алфавитов.

# Required:    no
# Recommended: libunistring
# Optional:    git
#              gtk-doc (для создания API документации)

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
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Internationalized Domain Name library version 2)
#
# libidn is a package designed for internationalized string handling based on
# the Stringprep, Punycode and IDNA specifications defined by the Internet
# Engineering Task Force (IETF) Internationalized Domain Names (IDN) working
# group, used for internationalized domain names. This is useful for converting
# data from the systems native representation into UTF-8, transforming Unicode
# strings into ASCII strings, allowing applications to use certain ASCII name
# labels (beginning with a special prefix) to represent non-ASCII name labels,
# and converting entire domain names to and from the ASCII Compatible Encoding
# (ACE) form.
#
# Home page: https://www.gnu.org/software/libidn/
# Download:  https://ftpmirror.gnu.org/libidn/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
