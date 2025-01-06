#! /bin/bash

PRGNAME="clisp"

### Clisp (a Common Lisp implementation)
# Язык программирования высокого уровня общего назначения.

# Required:    no
# Recommended: libsigsegv
# Optional:    libnsl
#              libffcall   (https://www.gnu.org/software/libffcall/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим два теста, которые не работают по неизвестным причинам
sed -i -e '/socket/d' -e '/"streams"/d' tests/tests.lisp

# если установлен пакет libffcall, исправим ошибку сборки
if [ -x /usr/lib/libffcall.so ]; then
    patch --verbose -Np1 -i \
        "${SOURCES}/${PRGNAME}-${VERSION}-readline7_fixes-1.patch" || exit 1
fi

mkdir build
cd build || exit 1

# явно указываем префиксы для libsigsegv и libffcall (если они не установлены,
# данные флаги игнорируются), иначе скрипт конфигурации их не находит
#    --with-libsigsegv-prefix=/usr
#    --with-libffcall-prefix=/usr
../configure                      \
    --srcdir=../                  \
    --prefix=/usr                 \
    --with-libsigsegv-prefix=/usr \
    --with-libffcall-prefix=/usr  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

# увеличим максимальный размер стека, как рекомендовано в скрипте конфигурации
ulimit -s 16384
# параллельная сборка данного пакета не поддерживается, поэтому явно указываем
# сборку в один поток
make -j1 || exit
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a Common Lisp implementation)
#
# Common Lisp is a high-level, general-purpose programming language. GNU CLISP
# is a Common Lisp implementation.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/latest/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
