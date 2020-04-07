#! /bin/bash

PRGNAME="zstd"

### Zstandard (real-time compression algorithm)
# Real-time алгоритм сжатия, обеспечивающий относительно высокую степень сжатия
# и поддерживается очень быстрым декодером

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/zstd.html

# Home page: https://facebook.github.io/zstd/
# Download:  https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

make || exit 1

make prefix=/usr install
make prefix=/usr install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -v /usr/lib/libzstd.a
rm -v "${TMP_DIR}/usr/lib/libzstd.a"

# переместим libzstd.so.* из /usr/lib в /lib
mv -v /usr/lib/libzstd.so.* /lib
mv -v "${TMP_DIR}/usr/lib/libzstd.so."* "${TMP_DIR}/lib"

# воссоздадим ссылку в /usr/lib libzstd.so -> ../../lib/libzstd.so.${VERSION}
ln -svf "../../lib/$(readlink /usr/lib/libzstd.so)" /usr/lib/libzstd.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "../../lib/$(readlink libzstd.so)" libzstd.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (real-time compression algorithm)
#
# Zstandard is a real-time compression algorithm, providing high compression
# ratios. It offers a very wide range of compression/speed trade-off, while
# being backed by a very fast decoder. It also offers a special mode for small
# data, called dictionary compression, and can create dictionaries from any
# sample set.
#
# Home page: https://facebook.github.io/${PRGNAME}/
# Download:  https://github.com/facebook/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
