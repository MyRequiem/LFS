#! /bin/bash

PRGNAME="libseccomp"

### libseccomp
# Пакет предоставляет простой в использовании и независимый от платформы
# интерфейс к механизму фильтрации системных вызовов ядра Linux

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libseccomp.html

# Home page: https://github.com/seccomp/libseccomp
# Download:  https://github.com/seccomp/libseccomp/releases/download/v2.4.1/libseccomp-2.4.1.tar.gz

# Required: no
# Optional: which (needed for tests)
#           valgrind
#           cython
#           lcov

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Enhanced Seccomp library)
#
# The libseccomp library provides an easy to use, platform independent,
# interface to the Linux Kernel's syscall filtering mechanism. The libseccomp
# API is designed to abstract away the underlying BPF based syscall filter
# language and present a more conventional function-call based filtering
# interface that should be familiar to, and easily adopted by, application
# developers
#
# Home page: https://github.com/seccomp/${PRGNAME}
# Download:  https://github.com/seccomp/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
