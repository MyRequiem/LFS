#! /bin/bash

PRGNAME="zlib"

### Zlib
# Универсальная многопоточная библиотека сжатия данных

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/zlib.html

# Home page: https://www.zlib.net/
# Download:  https://zlib.net/zlib-1.2.11.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
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
mv -v /usr/lib/libz.so.* /lib
# /usr/lib/libz.so -> ../../lib/libz.so.${VERSION}
ln -sfv ../../lib/"$(readlink /usr/lib/libz.so)" /usr/lib/libz.so

cd "${TMP_DIR}" || exit 1
mkdir -pv lib
mv -v usr/lib/libz.so.* lib/
ln -sfv ../../lib/"$(readlink usr/lib/libz.so)" usr/lib/libz.so

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (compression library)
#
# Zlib is a general purpose thread safe data compression library.
#
# Home page: https://www.zlib.net/
# Download:  https://zlib.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
