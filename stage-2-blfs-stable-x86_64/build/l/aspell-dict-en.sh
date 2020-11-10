#! /bin/bash

PRGNAME="aspell-dict-en"
ARCH_NAME="aspell6-en"
VERSION="2019.10.06-0"

### English dictionary for Aspell

# Required:    aspell
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                                 || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" "${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (English dictionary for Aspell)
#
# GNU Aspell English Dictionary Package
#
# Home page: https://ftp.gnu.org/gnu/aspell/dict/en/
# Download:  https://ftp.gnu.org/gnu/aspell/dict/en/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
