#! /bin/bash

PRGNAME="gc"

### GC (Boehm-Demers-Weiser Garbage Collector)
# Библиотека автоматического управления памятью для языков C/C++ (сборщик
# мусора). Помогает программам (например, w3m) эффективно освобождать
# оперативную память, предотвращая её утечки.

# Required:    no
# Recommended: no
# Optional:    libatomic-ops

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man3"
mkdir -pv "${TMP_DIR}${MAN}"

# соберем C++ библиотеку вместе со стандартной библиотекой C
#    --enable-cplusplus
./configure            \
    --prefix=/usr      \
    --enable-cplusplus \
    --disable-static   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

install -v -m644 "doc/${PRGNAME}.man" "${TMP_DIR}${MAN}/${PRGNAME}_malloc.3"
ln -svf "${PRGNAME}_malloc.3" "${TMP_DIR}${MAN}/${PRGNAME}.3"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Boehm-Demers-Weiser Garbage Collector)
#
# The GC package contains the Boehm-Demers-Weiser conservative garbage
# collector, which can be used as a garbage collecting replacement for the C
# malloc function or C++ new operator. It allows you to allocate memory
# basically as you normally would, without explicitly deallocating memory that
# is no longer useful. The collector automatically recycles memory when it
# determines that it can no longer be otherwise accessed. The collector is also
# used by a number of programming language implementations that either use C as
# intermediate code, want to facilitate easier interoperation with C libraries,
# or just prefer the simple collector interface. Alternatively, the garbage
# collector may be used as a leak detector for C or C++ programs, though that
# is not its primary goal.
#
# Home page: https://github.com/bdwgc/bdwgc/
# Download:  https://github.com/bdwgc/bdwgc/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
