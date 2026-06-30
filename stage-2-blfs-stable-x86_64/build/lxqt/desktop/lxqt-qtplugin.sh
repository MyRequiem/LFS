#! /bin/bash

PRGNAME="lxqt-qtplugin"

### lxqt-qtplugin (an LXQt Qt platform integration plugin)
# Специальный системный плагин, который интегрирует настройки оболочки LXQt
# напрямую в фреймворк Qt. Он гарантирует, что любые сторонние Qt-программы
# будут автоматически использовать выбранную пользователем тему оформления,
# шрифты и значки.

# Required:    libfm-qt
#              liblxqt
#              libdbusmenu-lxqt
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (an LXQt Qt platform integration plugin)
#
# The lxqt-qtplugin package provides an LXQt Qt platform integration plugin
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
