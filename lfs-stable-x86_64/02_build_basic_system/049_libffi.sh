#! /bin/bash

PRGNAME="libffi"

### Libffi
# Libffi - библиотека, которая предоставляет переносимый программный интерфейс
# высокого уровня для различных соглашений о вызовах. Это позволяет
# программисту вызывать любую функцию определенную описанием интерфейса вызова
# во время выполнения

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libffi.html

# Home page: https://sourceware.org/libffi/
# Download:  ftp://sourceware.org/pub/libffi/libffi-3.3.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# GCC будет проводить оптимизацию сборки для текущей системы
#    --with-gcc-arch=native
./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-gcc-arch=native || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Portable Foreign Function Interface Library)
#
# FFI stands for Foreign Function Interface. A foreign function interface is
# the popular name for the interface that allows code written in one language
# to call code written in another language. This allows a programmer to call
# any function specified by a call interface description at run time. The
# libffi library really only provides the lowest, machine dependent layer of a
# fully featured foreign function interface.
#
# Home page: https://sourceware.org/${PRGNAME}/
# Download:  ftp://sourceware.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
