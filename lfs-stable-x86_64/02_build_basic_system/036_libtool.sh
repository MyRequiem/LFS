#! /bin/bash

PRGNAME="libtool"

### Libtool
# Пакет содержит скрипт поддержки универсальной библиотеки GNU. Оборачивает
# сложность использования разделяемых библиотек в согласованном, переносимом
# интерфейсе

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libtool.html

# Home page: http://www.gnu.org/software/libtool/
# Download:  http://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1

### запуск набора тестов
# в данном случае для сокращения времени тестирования тесты можно запускать в
# несколько потоков (количество ядер процессора + 1)
MAKEFLAGS="-j$(($(/tools/bin/nproc) + 1))"
# известно, что пять тестов не проходят в среде сборки LFS из-за наличия
# кольцевых зависимостей, но после установки automake все тесты проходят
make "${MAKEFLAGS}" check

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a generic library support script)
#
# This is GNU Libtool, a generic GNU libraries support script. Libtool hides
# the complexity of using shared libraries behind a consistent, portable
# interface. To use libtool, add the new generic library building commands to
# your Makefile, Makefile.in, or Makefile.am.
#
# Requires 'm4' package.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
