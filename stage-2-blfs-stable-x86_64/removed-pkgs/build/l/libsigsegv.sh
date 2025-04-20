#! /bin/bash

PRGNAME="libsigsegv"

### libsigsegv (user mode page fault handling library)
# Библиотека для обработки ошибок страниц памяти в пользовательском режиме.
# Ошибка страницы происходит, когда программа пытается получить доступ к
# области памяти, которая в данный момент не доступна. Перехват и обработка
# страничной ошибки является полезным методом для реализации выгружаемой
# виртуальной памяти, доступа к памяти баз данных, сборщиков мусора (garbage
# collector), обработчиков переполнения стека и распределенной общей памяти.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
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
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (user mode page fault handling library)
#
# libsigsegv is a library for handling page faults in user mode. A page fault
# occurs when a program tries to access to a region of memory that is currently
# not available. Catching and handling a page fault is a useful technique for
# implementing pageable virtual memory, memory-mapped access to persistent
# databases, generational garbage collectors, stack overflow handlers, and
# distributed shared memory.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
