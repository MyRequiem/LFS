#! /bin/bash

PRGNAME="libunistring"

### libunistring (GNU Unicode string library)
# Библиотека для обработки строк в кодировке Unicode, позволяющая программам
# корректно работать с любыми языками мира.

# Required:    no
# Recommended: no
# Optional:    texlive или install-tl-unx (для пересборки документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с glibc >=2.43
# shellcheck disable=SC2046
# shellcheck disable=SC2185
sed -r '/_GL_EXTERN_C/s/w?memchr|bsearch/(&)/' \
    -i $(find -name \*.in.h) || exit 1

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Unicode string library)
#
# This library provides functions for manipulating Unicode strings and for
# manipulating C strings according to the Unicode standard.
#
# Home page: https://www.gnu.org/s/${PRGNAME}
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
