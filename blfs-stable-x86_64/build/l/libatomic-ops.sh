#! /bin/bash

PRGNAME="libatomic-ops"
ARCH_NAME="libatomic_ops"

### libatomic-ops (implementations for atomic memory update operations)
# Библиотеки, реализующие операции обновления памяти для ряда архитектур.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libatomic_ops.html

# Home page: https://github.com/ivmai/libatomic_ops
# Download:  https://github.com/ivmai/libatomic_ops/releases/download/v7.6.10/libatomic_ops-7.6.10.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (implementations for atomic memory update operations)
#
# Provides implementations for atomic memory update operations on a number of
# architectures. This allows direct use of these in reasonably portable code.
# Unlike earlier similar packages, this one explicitly considers memory barrier
# semantics, and allows the construction of code that involves minimum overhead
# across a variety of architectures.
#
# Home page: https://github.com/ivmai/${ARCH_NAME}
# Download:  https://github.com/ivmai/${ARCH_NAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
