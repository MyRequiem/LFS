#! /bin/bash

PRGNAME="pth"

### Pth (GNU Portable Threads Library)
# Библиотека для управления потоками в пользовательском пространстве на основе
# POSIX/ANSI-C, которая обеспечивает планирование выполнения задач на основе
# приоритетов в многопоточных приложениях

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"/{bin,include,share/{aclocal,man/{man1,man3}}}

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
make install DESTDIR="${TMP_DIR}"

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}${DOCS}"
install -v -m644 README PORTING SUPPORT TESTS "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
