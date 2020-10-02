#! /bin/bash

PRGNAME="bison"

### Bison (parser generator similar to yacc)
# Пакет предназначен для автоматического создания синтаксических анализаторов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
