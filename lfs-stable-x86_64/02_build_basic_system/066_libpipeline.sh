#! /bin/bash

PRGNAME="libpipeline"

### Libpipeline
# Пакет содержит библиотеку для манипулирования конвейерами подпроцессов гибким
# и удобным способом

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libpipeline.html

# Home page: http://libpipeline.nongnu.org/
# Download:  http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.2.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for manipulating pipelines)
#
# The Libpipeline package contains a library for manipulating pipelines of
# subprocesses in a flexible and convenient way.
#
# Home page: http://libpipeline.nongnu.org/
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
