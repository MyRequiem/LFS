#! /bin/bash

PRGNAME="zlib"

### Zlib (compression library)
# Универсальная многопоточная библиотека сжатия данных

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# библиотеку libz.so.${VERSION} необходимо переместить из /usr/lib в /lib, а
# затем воссоздать файл libz.so в /usr/lib
# было в /usr/lib:
#    libz.so   -> libz.so.${VERSION}
#    libz.so.1 -> libz.so.${VERSION}
# стало:
#    в /lib
#       libz.so.1 -> libz.so.${VERSION}
#    в /usr/lib
#       libz.so -> ../../lib/libz.so.${VERSION}
(
    cd "${TMP_DIR}" || exit 1
    mv -v usr/lib/libz.so.* lib/
    ln -sfv "../../lib/$(readlink usr/lib/libz.so)" usr/lib/libz.so
)

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (compression library)
#
# Zlib is a general purpose thread safe data compression library.
#
# Home page: https://www.zlib.net/
# Download:  https://zlib.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
