#! /bin/bash

PRGNAME="bc"

### Bc
# Язык обработки чисел произвольной точности

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/bc.html

# Home page: https://github.com/gavinhoward/bc
# Download:  https://github.com/gavinhoward/bc/archive/2.1.3/bc-2.1.3.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# определяем используемый компилятор и С-стандарт
#    CC=gcc
#    CFLAGS="-std=c99"
# указываем оптимизацию для компилятора
#    -O3
# пропустим те части тестового набора, которые не будут работать без
# присутствия GNU bc
#    -G
PREFIX=/usr \
CC=gcc CFLAGS="-std=c99" \
./configure.sh \
    -O3 \
    -G || exit 1

make || exit 1
make test
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (An arbitrary precision numeric processing language)
#
# bc is an arbitrary precision numeric processing language. Syntax is similar
# to C, but differs in many substantial areas. It supports interactive
# execution of statements.
#
# Home page: https://github.com/gavinhoward/bc
# Download:  https://github.com/gavinhoward/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
