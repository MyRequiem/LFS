#! /bin/bash

PRGNAME="libunwind"

### libunwind (API to determine the call-chain of a program)
# Мощный инструмент для анализа работы программ (портативный API C
# программирования), который позволяет «размотать» цепочку функций, приведших к
# текущему моменту. Это незаменимо для поиска причин сбоев и детальной отладки
# сложного софта.

# Required:    no
# Recommended: no
# Optional:    texlive (требуется утилита latex2man)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему сборки с GCC >=15
sed -i '/func.s/s/s//' tests/Gtest-nomalloc.c || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
