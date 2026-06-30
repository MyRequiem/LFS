#! /bin/bash

PRGNAME="libqtxdg"

### libqtxdg (Qt implementation freedesktop.org XDG specifications)
# Вспомогательная библиотека для правильной обработки стандартов
# freedesktop.org внутри графической среды LXQt. Она отвечает за корректную
# загрузку иконок, ярлыков приложений и типов файлов.

# Required:    cmake
#              lxqt-build-tools
#              qt6
# Recommended: no
# Optional:    --- runtime ---
#              gtk+3
#              xterm

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake ..                         \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt implementation freedesktop.org XDG specifications)
#
# The libqtxdg package contains a Qt implementation of the freedesktop.org XDG
# specifications
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
