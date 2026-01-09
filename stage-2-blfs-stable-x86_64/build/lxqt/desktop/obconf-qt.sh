#! /bin/bash

PRGNAME="obconf-qt"

### obconf-qt (Qt-based configuration tool for Openbox)
# Инструмент настройки Openbox на основе Qt

# Required:    hicolor-icon-theme
#              lxqt-build-tools
#              openbox
#              qt6
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# это последний пакет из раздела LXQt Desktop Components, поэтому обновим
# некоторые базы
ldconfig                             &&
update-mime-database /usr/share/mime &&
xdg-icon-resource forceupdate        &&
update-desktop-database -q           || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qt-based configuration tool for Openbox)
#
# The obconf-qt package is a Qt-based configuration tool for Openbox
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
