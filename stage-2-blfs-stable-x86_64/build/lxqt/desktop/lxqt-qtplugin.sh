#! /bin/bash

PRGNAME="lxqt-qtplugin"

### lxqt-qtplugin (an LXQt Qt platform integration plugin)
# Плагин интеграции платформы LXQt Qt

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

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

###
# WARNINIG
###
# Пакет устанавливает плагин в директорию /opt/qt6
#    /opt/qt6/plugins/platformthemes/libqtlxqt.so
# но /opt/qt6 является ссылкой на директорию qt6-x.x.x
#
# В данном случае плагин установлен в директорию
#    DESTDIR/opt/qt6/plugins/platformthemes/
# поэтому при копировании директории DESTDIR/opt/qt6 в корень системы
# произойдет ошибка, т.к. существует ссылка /opt/qt6
#
# Переименуем DESTDIR/opt/qt6 в qt6-x.x.x
REAL_QT6DIR="/opt/$(readlink "${QT6DIR}")"
mv "${TMP_DIR}${QT6DIR}" "${TMP_DIR}${REAL_QT6DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
