#! /bin/bash

PRGNAME="libseccomp"

### libseccomp (Enhanced Seccomp library)
# Библиотека, обеспечивающая простой в использовании, платформонезависимый
# интерфейс механизма фильтрации системных вызовов ядра Linux

# Required:    no
# Recommended: no
# Optional:    which    (для тестов)
#              valgrind
#              lcov     (https://github.com/linux-test-project/lcov)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Enhanced Seccomp library)
#
# The libseccomp library provides an easy to use, platform independent,
# interface to the Linux Kernel's syscall filtering mechanism. The libseccomp
# API is designed to abstract away the underlying BPF based syscall filter
# language and present a more conventional function-call based filtering
# interface that should be familiar to, and easily adopted by, application
# developers.
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
