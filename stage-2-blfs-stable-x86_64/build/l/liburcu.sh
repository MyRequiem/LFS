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
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
MINVERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${MINVERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-latest-${MINVERSION}".tar.?z* || exit 1
VERSION="$(find . -type d -name "${ARCH_NAME}-${MINVERSION}*" | rev | \
    cut -d - -f 1 | rev)"
cd "${ARCH_NAME}-${VERSION}" || exit 1

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
# Home page: http://${PRGNAME}.org/
# Download:  https://lttng.org/files/urcu/${ARCH_NAME}-latest-${MINVERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
