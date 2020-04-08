#! /bin/bash

PRGNAME="gperf"

### Gperf
# Генерирует наилучшую хеш-функцию из набора ключей

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gperf.html

# Home page: http://www.gnu.org/software/gperf/
# Download:  http://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# тесты Gperf не проходят в многопоточном режиме, поэтому явно укажем -j1
make -j1 check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a perfect hash function generator)
#
# gperf is a perfect hash function generator written in C++. It transforms an n
# element user-specified keyword set W into a perfect hash function F. Gperf
# currently generates the reserved keyword recognizer for lexical analyzers in
# several production and research compilers and language processing tools,
# including GNU C, GNU C++, GNU Java, GNU Pascal, GNU Modula 3, and GNU indent.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
