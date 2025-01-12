#! /bin/bash

PRGNAME="extra-cmake-modules"

### extra-cmake-modules (extra KDE CMake modules)
# дополнительные модули CMake, необходимые для компиляции KDE Frameworks 5

# Required:    cmake
# Recommended: no
# Optional:    python3-sphinx
#              python3-pyqt    (https://pypi.org/project/PyQt5/)
#              reusetool       (https://github.com/fsfe/reuse-tool/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# запретим приложениям, использующих cmake, пытаться установить файлы в
# [/usr]/lib64
sed -i '/"lib64"/s/64//' kde-modules/KDEInstallDirsCommon.cmake || exit 1

# защитим глобальную переменную cmake PACKAGE_PREFIX_DIR от изменений
sed -e '/PACKAGE_INIT/i set(SAVE_PACKAGE_PREFIX_DIR "${PACKAGE_PREFIX_DIR}")' \
    -e '/^include/a set(PACKAGE_PREFIX_DIR "${SAVE_PACKAGE_PREFIX_DIR}")'     \
    -i ECMConfig.cmake.in || exit 1

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (extra KDE CMake modules)
#
# This package contains additional CMake modules required for compiling KDE
# Frameworks 5
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/frameworks/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
