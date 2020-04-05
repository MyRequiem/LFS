#! /bin/bash

PRGNAME="bison"

### Bison
# Пакет предназначен для автоматического создания синтаксических анализаторов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/bison.html

# Home page: http://www.gnu.org/software/bison/
# Download:  http://ftp.gnu.org/gnu/bison/bison-3.4.1.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим проблему с текущей версией
sed -i '6855 s/mv/cp/' Makefile.in

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

# явно указываем сборку в 1 поток
make -j1 || exit 1
# существует циклическая зависимость между bison и flex в отношении тестов,
# поэтому тесты в данный момент не запускаем, а сразу устанавливаем пакет
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (parser generator similar to yacc)
#
# GNU "Bison" is a general-purpose parser generator that converts a grammar
# description for an LALR(1) context-free grammar into a C program to parse
# that grammar.
# Bison is upward compatible with Yacc: all properly-written Yacc grammars
# ought to work with Bison with no change. Anyone familiar with Yacc should be
# able to use Bison with little trouble.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
