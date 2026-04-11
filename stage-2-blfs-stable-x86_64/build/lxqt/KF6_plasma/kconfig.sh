#! /bin/bash

PRGNAME="kconfig"

### kconfig (access to configuration files)
# Предоставляет доступ к файлам конфигурации

# Required:    extra-cmake-modules
#              qt6
# Recommended: no
# Optional:    no

###
# NOTE:
#    Нет необходимости в этом пакете, если установлен пакет kde-frameworks
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=Release         \
    -D CMAKE_INSTALL_LIBEXECDIR=libexec \
    -D KDE_INSTALL_USE_QT_SYS_PATHS=ON  \
    -D BUILD_TESTING=OFF                \
    -W no-dev                           \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

###
# WARNINIG
###
# Пакет устанавливает плагин в директорию /opt/qt6
#    /opt/qt6/qml/org/kde/config/libKF6ConfigQmlplugin.so
# но /opt/qt6 является ссылкой на директорию qt6-x.x.x
#
# В данном случае плагин установлен в директорию
#    DESTDIR/opt/qt6/qml/org/kde/config/
# поэтому при копировании директории DESTDIR/opt/qt6 в корень системы
# произойдет ошибка, т.к. существует ссылка /opt/qt6
#
# Переименуем DESTDIR/opt/qt6 в qt6-x.x.x
REAL_QT6DIR="/opt/$(readlink "${QT6DIR}")"
mv "${TMP_DIR}${QT6DIR}" "${TMP_DIR}${REAL_QT6DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (access to configuration files)
#
# The kconfig package provides access to configuration files
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/frameworks/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
