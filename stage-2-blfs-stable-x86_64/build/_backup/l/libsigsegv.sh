#! /bin/bash

PRGNAME="libsigsegv"

### libsigsegv (user mode page fault handling library)
# Библиотека для обработки ошибок страниц памяти в пользовательском режиме,
# т.е. ошибки возникающие тогда, когда программа пытается получить доступ к
# области памяти, которая в данный момент не доступна. Является полезной при
# реализация таких вещей как постраничная виртуальная память, работа со
# сборщиками мусора (garbage collectors), обработка ошибок переполнение стека,
# работа с распределенной общей памятью и многое другое.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libsigsegv.html

# Home page: http://www.gnu.org/software/libsigsegv/
# Download:  https://ftp.gnu.org/gnu/libsigsegv/libsigsegv-2.12.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure         \
    --prefix=/usr   \
    --enable-shared \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (user mode page fault handling library)
#
# This is a library for handling page faults in user mode. A page fault occurs
# when a program tries to access to a region of memory that is currently not
# available. Catching and handling a page fault is a useful technique for
# implementing things such as pageable virtual memory, memory-mapped access to
# persistent databases, generational garbage collectors, stack overflow
# handlers, distributed shared memory, and more.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
