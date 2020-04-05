#! /bin/bash

PRGNAME="npth"

### NPth (New GNU Portable Threads Library)
# Библиотека для управления потоками в пользовательском пространстве на основе
# POSIX/ANSI-C, которая обеспечивает планирование выполнения задач на основе
# приоритетов в многопоточных приложениях. Является более совершенной заменой
# для стандартной библиотеки GNU Pth, последний корректирующий релиз которой
# вышел в 2006 году. C тех пор проект Pth не развивается. Так как новая
# библиотека представляет интерес и для других проектов, было принято решение
# развивать nPth в виде обособленного продукта.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/npth.html

# Home page: https://gnupg.org/software/npth/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (New GNU Portable Threads)
#
# nPth is a non-preemptive threads implementation using an API very similar to
# the one known from GNU Pth. It has been designed as a replacement of GNU Pth
# for non-ancient operating systems. In contrast to GNU Pth is is based on the
# system's standard threads implementation. Thus nPth allows the use of
# libraries which are not compatible to GNU Pth
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
