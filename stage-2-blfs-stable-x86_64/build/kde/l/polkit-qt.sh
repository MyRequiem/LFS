#! /bin/bash

PRGNAME="polkit-qt"
ARCH_NAME="polkit-qt-1"

### Polkit-Qt (Qt polkit API wrapper)
# Предоставляет API для PolicyKit в среде Qt

# Required:    cmake
#              polkit
#              qt6
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D QT_MAJOR_VERSION=6        \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt polkit API wrapper)
#
# Polkit-Qt provides an API to PolicyKit in the Qt environment
#
# Home page: https://download.kde.org/stable/${ARCH_NAME}/
# Download:  https://download.kde.org/stable/${ARCH_NAME}/${ARCH_NAME}-0.200.0.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
