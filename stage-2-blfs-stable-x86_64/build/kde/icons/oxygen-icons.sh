#! /bin/bash

PRGNAME="oxygen-icons"

### oxygen-icons (Oxygen theme for KDE)
# современная тема иконок для KDE

# Required:    extra-cmake-modules
#              qt6
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включим масштабируемые иконки
sed -i '/( oxygen/ s/)/scalable )/' CMakeLists.txt || exit 1

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -W no-dev                    \
    .. || exit 1

# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Oxygen theme for KDE)
#
# Oxygen provides a complete and modern icon theme for KDE
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
