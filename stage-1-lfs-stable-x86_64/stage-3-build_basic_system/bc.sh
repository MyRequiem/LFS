#! /bin/bash

PRGNAME="bc"

### Bc (An arbitrary precision numeric processing language)
# Язык обработки чисел произвольной точности

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# определяем используемый компилятор и С-стандарт
#    CC=gcc
#    CFLAGS="-std=c99"
# пропустим те части тестового набора, которые не будут работать без уже
# установленного GNU bc
#    -G
# указываем оптимизацию для компилятора
#    -O3
PREFIX=/usr       \
CC=gcc            \
CFLAGS="-std=c99" \
./configure.sh    \
    -G            \
    -O3 || exit 1

make || make -j1 || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (An arbitrary precision numeric processing language)
#
# bc is an arbitrary precision numeric processing language. Syntax is similar
# to C, but differs in many substantial areas. It supports interactive
# execution of statements.
#
# Home page: https://github.com/gavinhoward/bc
# Download:  https://github.com/gavinhoward/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
