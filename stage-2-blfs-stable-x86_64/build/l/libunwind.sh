#! /bin/bash

PRGNAME="libunwind"

### libunwind (API to determine the call-chain of a program)
# libunwind содержит портативный интерфейс программирования C (API) для
# определения цепочки вызовов программы

# Required:    no
# Recommended: no
# Optional:    texlive (требуется утилита latex2man)

ROOT="/root/src/lfs"
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
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (API to determine the call-chain of a program)
#
# The primary goal of libunwind is to define a portable and efficient C
# programming interface (API) to determine the call-chain of a program. The API
# additionally provides the means to manipulate the preserved (callee-saved)
# state of each call-frame and to resume execution at any point in the
# call-chain (non-local goto). Some uses for this API include exception
# handling, debuggers, introspection, or implementing an extremely efficient
# version of setjmp()
#
# Home page: https://www.nongnu.org/${PRGNAME}/
# Download:  https://download.savannah.nongnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
