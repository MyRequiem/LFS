#! /bin/bash

PRGNAME="oniguruma"
ARCH_NAME="onig"

### oniguruma (Regular expressions library)
# Библиотека регулярных выражений. Для каждого регулярного выражения может быть
# указана разная кодировка символов.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --disable-static     \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Regular expressions library)
#
# Oniguruma is a regular expressions library. The characteristics of this
# library is that different character encoding for every regular expression
# object can be specified.
#
# Home page: https://github.com/kkos/${PRGNAME}
# Download:  https://github.com/kkos/${PRGNAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
