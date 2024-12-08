#! /bin/bash

PRGNAME="liburcu"
ARCH_NAME="userspace-rcu"

### liburcu (Read-Copy-Update Library)
# Библиотека обеспечивающая механизм синхронизации для реализации параллельного
# чтения и записи

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Read-Copy-Update Library)
#
# liburcu is a userspace RCU (read-copy-update) library. This data
# synchronization library provides read-side access which scales linearly with
# the number of cores.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://lttng.org/files/urcu/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
