#! /bin/bash

PRGNAME="breeze-icons"

### breeze-icons (Breeze icon themes for KDE Plasma)
# Набор иконок, используемый по умолчанию в среде рабочего стола KDE Plasma и
# приложениях

# Required:    extra-cmake-modules
#              qt6
# Recommended: no
# Optional:    kde-frameworks
#              libxml2
#              python3-lxml

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_TESTING=OFF         \
    -W no-dev                    \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Breeze icon themes for KDE Plasma)
#
# The Breeze Icons package contains the default icons for KDE Plasma
# applications, but it can be used for other window environments
#
# Home page: https://github.com/KDE/${PRGNAME}
# Download:  https://download.kde.org/stable/frameworks/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
