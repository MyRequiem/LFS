#! /bin/bash

PRGNAME="qt5-components"
ARCH_NAME="qt-everywhere-opensource-src"

### Qt (a multi-platform C++ graphical user interface toolkit)
# Кроссплатформенный C++ фреймворк, широко использующийся для разработки
# прикладного программного обеспечения с графическим пользовательским
# интерфейсом (GUI), а также для разработки программ без графического
# интерфейса (инструменты командной строки и консоли для серверов). Одним из
# основных пользователей Qt является KDE Frameworks 5 (KF5)

# Required:    xorg-libraries
# Recommended: alsa-lib
#              at-spi2-core
#              cups
#              dbus
#              double-conversion
#              glib
#              harfbuzz
#              icu
#              hicolor-icon-theme
#              mesa
#              libjpeg-turbo
#              libxkbcommon
#              sqlite
#              wayland
#              xcb-util-image
#              xcb-util-keysyms
#              xcb-util-renderutil
#              xcb-util-wm
# Optional:    gtk+3
#              libinput
#              mariadb или mysql (https://www.mysql.com/)
#              mit-kerberos-v5
#              mtdev
#              postgresql
#              unixodbc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "qt-everywhere-src-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"

# NOTE:
# Qt5 рекомендуется устанавливать в каталог, отличный от /usr, поэтому будем
# устанавливать в /opt/qt5-${VERSION}
export QT5PREFIX=/opt/qt5

# /etc
#     |
#     profile.d/qt5.sh
#     sudoers.d/qt
# /usr
#     |
#     bin/
# /opt
#     |
#     qt5               (ссылка на qt5-${VERSION}/)
#     qt5-${VERSION}/

mkdir -pv "${TMP_DIR}"/{etc/{profile.d,sudoers.d,ld.so.conf.d},usr/bin}
mkdir -pv "${TMP_DIR}${QT5PREFIX}-${VERSION}"
# qt5 -> qt5-${VERSION}
ln -sv "qt5-${VERSION}" "${TMP_DIR}${QT5PREFIX}-${VERSION}/../qt5"

# исправления, предложенные KDE
patch -Np1 --verbose -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-kf5-1.patch" || exit 1

# патч предполагает наличие git репозитория
mkdir -pv qtbase/.git

# список компонентов в файле tempconf, которые будут пропущены при компиляции
# shellcheck disable=SC2010
ls -Fd qt* | grep / | sed 's/^/-skip /;s@/@@' > tempconf || exit 1
sed -i -r '/base|tools|x11extras|svg|declarative|wayland/d' tempconf

# -----------
# ./tempconf
# -----------
# -skip qt3d
# -skip qtactiveqt
# -skip qtandroidextras
# -skip qtcharts
# -skip qtconnectivity
# -skip qtdatavis3d
# -skip qtdoc
# -skip qtgamepad
# -skip qtgraphicaleffects
# -skip qtimageformats
# -skip qtlocation
# -skip qtlottie
# -skip qtmacextras
# -skip qtmultimedia
# -skip qtnetworkauth
# -skip qtpurchasing
# -skip qtquick3d
# -skip qtquickcontrols
# -skip qtquickcontrols2
# -skip qtquicktimeline
# -skip qtremoteobjects
# -skip qtscript
# -skip qtscxml
# -skip qtsensors
# -skip qtserialbus
# -skip qtserialport
# -skip qtspeech
# -skip qttranslations
# -skip qtvirtualkeyboard
# -skip qtwebchannel
# -skip qtwebengine
# -skip qtwebglplugin
# -skip qtwebsockets
# -skip qtwebview
# -skip qtwinextras
# -skip qtxmlpatterns

# shellcheck disable=SC2046
./configure                \
    -prefix "${QT5PREFIX}" \
    -sysconfdir /etc/xdg   \
    -confirm-license       \
    -opensource            \
    -dbus-linked           \
    -openssl-linked        \
    -system-harfbuzz       \
    -system-sqlite         \
    -nomake examples       \
    -nomake tests          \
    -no-rpath              \
    -syslog                \
    $(cat tempconf) || exit 1

make || exit 1
# пакет не имеет набора тестов
make install INSTALL_ROOT="${TMP_DIR}"

# удалим ссылки на каталог сборки из установленных библиотек
#    /opt/qt5/lib/libQt5Purchasing.prl
#    /opt/qt5/lib/libQt5MultimediaQuick.prl
#    ...
find "${TMP_DIR}${QT5PREFIX}"/ -name "*.prl" \
    -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;

QT5BINDIR="${QT5PREFIX}/bin"
# некоторые пакеты, например vlc, ищут определенные исполняемые файлы в
# /usr/bin с суффиксом -qt5, поэтому создадим необходимые ссылки
#    /usr/bin/qmake-qt5 -> /opt/qt5-${VERSION}/bin/qmake
#    /usr/bin/moc-qt5   -> /opt/qt5-${VERSION}/bin/moc
#    ...
for FILE in moc uic rcc qmake lconvert lrelease lupdate; do
    ln -sfv "../..${QT5BINDIR}/${FILE}" "${TMP_DIR}/usr/bin/${FILE}-qt5"
done

# добавим путь поиска библиотек для динамического загрузчика
cat << EOF > "${TMP_DIR}/etc/ld.so.conf.d/qt5.conf"
/opt/qt5/lib
EOF

# QT5DIR также должен быть доступен пользователю root
cat << EOF > "${TMP_DIR}/etc/sudoers.d/qt"
Defaults env_keep += QT5DIR
EOF
chmod 440 "${TMP_DIR}/etc/sudoers.d/qt"

QT5_SH="/etc/profile.d/qt5.sh"
cat << EOF > "${TMP_DIR}${QT5_SH}"
# Begin ${QT5_SH}

QT5DIR=${QT5PREFIX}

PATH="\${PATH}:\${QT5DIR}/bin"
PKG_CONFIG_PATH="\${PKG_CONFIG_PATH}:\${QT5DIR}/lib/pkgconfig"

export QT5DIR PATH PKG_CONFIG_PATH

# End ${QT5_SH}
EOF
chmod 755 "${TMP_DIR}${QT5_SH}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш динамического загрузчика
ldconfig

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a multi-platform C++ graphical user interface toolkit)
#
# Qt5 is a cross-platform C++ application framework that is widely used for
# developing application software with a graphical user interface (GUI) (in
# which cases Qt5 is classified as a widget toolkit), and also used for
# developing non-GUI programs such as command-line tools and consoles for
# servers. One of the major users of Qt is KDE Frameworks 5 (KF5).
#
# Home page: https://qt-project.org/
# Download:  https://download.qt.io/archive/qt/${MAJ_VERSION}/${VERSION}/single/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
