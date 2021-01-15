#! /bin/bash

PRGNAME="ruby"

### Ruby (Interpreted object-oriented scripting language)
# Объектно-ориентированный, интерпретируемый язык программирования.

# Required:    no
# Recommended: no
# Optional:    berkeley-db
#              doxygen
#              graphviz
#              libyaml
#              tk
#              valgrind
#              dtrace (http://dtrace.org/blogs/about/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

VALGRIND="--without-valgrind"
DTRACE="--disable-dtrace"

command -v valgrind &>/dev/null && VALGRIND="--with-valgrind"
command -v dtrace   &>/dev/null && DTRACE="--enable-dtrace"

./configure \
    --prefix=/usr   \
    --enable-shared \
    "${VALGRIND}"   \
    "${DTRACE}"     \
    --docdir="${DOCS}" || exit 1

make || exit 1

# C API документация
# make capi || exit 1

# make check

make install DESTDIR="${TMP_DIR}"

cp -a BSDL COPYING ChangeLog NEWS.md README.md "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Interpreted object-oriented scripting language)
#
# Ruby is an interpreted scripting language for quick and easy object-oriented
# programming. It has many features to process text files and to do system
# management tasks (as in Perl). It is simple, straight-forward, and
# extensible.
#
# Home page: https://www.ruby-lang.org/
# Download:  http://cache.ruby-lang.org/pub/${PRGNAME}/${MAJ_VER}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
