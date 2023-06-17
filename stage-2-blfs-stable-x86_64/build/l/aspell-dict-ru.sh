#! /bin/bash

PRGNAME="aspell-dict-ru"
ARCH_NAME="aspell6-ru"
VERSION="0.99f7-1"

### Russian dictionary for Aspell

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
# Package: ${PRGNAME} (Russian dictionary for Aspell)
#
# GNU Aspell Russian Dictionary Package
#
# Home page: https://ftp.gnu.org/gnu/aspell/dict/ru/
# Download:  https://ftp.gnu.org/gnu/aspell/dict/ru/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
