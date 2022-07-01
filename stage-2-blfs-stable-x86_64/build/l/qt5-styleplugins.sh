#! /bin/bash

PRGNAME="qt5-styleplugins"
ARCH_NAME="qtstyleplugins"

### qt5-styleplugins (additional style plugins for Qt5)
# Дополнительные плагины стилей для Qt5

# Required:    python3
#              qt5
#              libxkbcommon
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# патчим для сборки с qt5-5.15.x
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix-build-against-Qt-5.15.patch" || exit 1
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fix-gtk2-background.patch"       || exit 1

# принудительно связываем с qt5dbus, иначе сборка завершится ошибкой
sed "s|2.0$|2.0 Qt5DBus|" -i src/plugins/platformthemes/gtk2/gtk2.pro  || exit 1

QMAKE_CFLAGS_RELEASE="-O2 -fPIC"   \
QMAKE_CXXFLAGS_RELEASE="-O2 -fPIC" \
qmake-qt5 || exit 1

make || exit 1
make install INSTALL_ROOT="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (additional style plugins for Qt5)
#
# Additional style plugins for Qt5
#
# Home page: https://code.qt.io/cgit/qt/${ARCH_NAME}.git/
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
