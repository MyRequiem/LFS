#! /bin/bash

PRGNAME="pth"

### Pth (GNU Portable Threads Library)
# Библиотека для управления потоками в пользовательском пространстве на основе
# POSIX/ANSI-C, которая обеспечивает планирование выполнения задач на основе
# приоритетов в многопоточных приложениях

# http://www.linuxfromscratch.org/blfs/view/9.0/general/pth.html

# Home page: http://www.gnu.org/software/pth/
# Download:  https://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}${DOCS}"

# позволим запускать make в несколько потоков (например, make -j4)
sed -i 's#$(LOBJS): Makefile#$(LOBJS): pth_p.h Makefile#' Makefile.in

# Внимание!!!
# нелязя добавлять параметр '--enable-pthread' в параметры конфигурации, т.к.
# произойдет перезапись библиотеки pthread (/usr/lib/libpthread.so) и
# заголовочных файлов, которые были установлены с пакетом Glibc
./configure          \
    --prefix=/usr    \
    --disable-static \
    --mandir=/usr/share/man || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

install -v -m755 -d "${DOCS}"
install -v -m644    README PORTING SUPPORT TESTS "${DOCS}"
install -v -m644    README PORTING SUPPORT TESTS "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Portable Threads)
#
# Pth is a very portable POSIX/ANSI-C based library for Unix platforms which
# provides non-preemptive priority-based scheduling for multiple threads of
# execution (aka 'multithreading') inside event-driven applications. All
# threads run in the same address space of the server application, but each
# thread has its own individual program-counter, run-time stack, signal mask
# and errno variable.
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
