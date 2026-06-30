#! /bin/bash

PRGNAME="ruby"

### Ruby (Interpreted object-oriented scripting language)
# Мощный объектно-ориентированный, интерпретируемый и выразительный язык
# программирования, на котором пишут всё: от простых автоматических скриптов до
# огромных веб-сайтов (например, GitHub). Он создан так, чтобы код на нём был
# максимально похож на обычный английский текст, что делает его удобным и
# приятным для чтения и написания.

# Required:    libyaml
# Recommended: no
# Optional:    doxygen
#              graphviz
#              rustc
#              tk
#              valgrind
#              berkeley-db    (https://www.oracle.com/database/technologies/related/berkeleydb.html)
#              dtrace         (https://dtrace.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --disable-rpath        \
    --enable-shared        \
    --without-valgrind     \
    --without-baseruby     \
    ac_cv_func_qsort_r=no  \
    --disable-install-doc  \
    --disable-install-rdoc \
    --disable-install-capi \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make -k check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Home page: https://www.${PRGNAME}-lang.org/
# Download:  https://cache.${PRGNAME}-lang.org/pub/${PRGNAME}/${MAJ_VER}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
