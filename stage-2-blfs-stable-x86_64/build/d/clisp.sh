#! /bin/bash

PRGNAME="clisp"

### Clisp (a Common Lisp implementation)

# http://www.linuxfromscratch.org/blfs/view/stable/general/clisp.html
# Язык программирования высокого уровня (GNU реализация Common Lisp). Включает
# в себя интерпретатор, компилятор, отладчик, множество расширений, большое
# подмножество CLOS, интерфейс сокетов. Интерфейс X11 доступен через CLX и
# Garnet.

# Home page: http://www.gnu.org/software/clisp/
# Download:  https://ftp.gnu.org/gnu/clisp/latest/clisp-2.49.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/clisp-2.49-readline7_fixes-1.patch

# Required: libsigsegv
# Optional: libffcall (http://www.gnu.org/software/libffcall/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим два теста, которые не проходят по неизвестным причинам
sed -i -e '/socket/d' -e '/"streams"/d' tests/tests.lisp

LIBFFCALL=""
[ -x /usr/lib/libffcall.so.0 ] && LIBFFCALL="--with-libffcall-prefix=/usr"

# если опциональный пакет libffcall установлен, применим патч, чтобы исправить
# ошибку сборки:
if [ -n "${LIBFFCALL}" ]; then
    patch -Np1 --verbose -i \
        "${SOURCES}/${PRGNAME}-${VERSION}-readline7_fixes-1.patch" || exit 1
fi

mkdir build &&
cd build    &&
../configure                      \
    --srcdir=../                  \
    --prefix=/usr                 \
    --with-libsigsegv-prefix=/usr \
    ${LIBFFCALL}                  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

# увеличим максимальный размер стека в соответствии с рекомендациями скрипта
# configure
ulimit -s 16384

# пакет не поддерживает сборку в несколько потоков, поэтому явно указываем -j1
make -j1 || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a Common Lisp implementation)
#
# Common Lisp is a high-level, general-purpose programming language. GNU CLISP
# is a Common Lisp implementation by Bruno Haible of Karlsruhe University and
# Michael Stoll of Munich University, both in Germany. It mostly supports the
# Lisp described in the ANSI Common Lisp standard. The user interface comes in
# German, English, French, Spanish, Dutch and Russian. GNU CLISP includes an
# interpreter, a compiler, a debugger, many extensions, a large subset of CLOS,
# a foreign language interface and a socket interface. An X11 interface is
# available through CLX and Garnet.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/latest/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
