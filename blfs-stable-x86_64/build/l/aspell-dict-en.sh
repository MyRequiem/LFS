#! /bin/bash

PRGNAME="aspell-dict-en"
ARCH_NAME="aspell6-en"
VERSION="2019.10.06-0"

### English dictionary for Aspell

# http://www.linuxfromscratch.org/blfs/view/9.0/general/aspell.html

# Home page: https://ftp.gnu.org/gnu/aspell/dict
# Download:  https://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-2019.10.06-0.tar.bz2

# Required: aspell
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                                 || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" "${VERSION}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure || exit 1
make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (English dictionary for Aspell)
#
# GNU Aspell English Dictionary Package
#
# Home page: https://ftp.gnu.org/gnu/aspell/dict
# Download:  https://ftp.gnu.org/gnu/aspell/dict/en/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
