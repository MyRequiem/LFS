#! /bin/bash

PRGNAME="qt5"
ARCH_NAME="qt-everywhere-src"

### Qt (a multi-platform C++ graphical user interface toolkit)
# Кроссплатформенный C++ фреймворк, широко использующийся для разработки
# прикладного программного обеспечения с графическим пользовательским
# интерфейсом (GUI), а также для разработки программ без графического
# интерфейса (инструменты командной строки и консоли для серверов). Одним из
# основных пользователей Qt является KDE Frameworks 5 (KF5)

# Required:    xorg-libraries
# Recommended: alsa-lib
#              make-ca
#              cups
#              glib
#              gst-plugins-base     (qtmultimedia backend)
#              harfbuzz
#              icu
#              jasper
#              libjpeg-turbo
#              libmng
#              libpng
#              libtiff
#              libwebp
#              libxkbcommon
#              mesa
#              mit-kerberos-v5
#              mtdev
#              pcre2
#              sqlite
#              wayland              (пакет mesa должен быть собран с wayland egl backend)
#              xcb-util-image
#              xcb-util-keysyms
#              xcb-util-renderutil
#              xcb-util-wm
# Optional:    bluez                (для сборки sdpscanner и для модуля qtconnectivity)
#              ibus
#              libinput
#              mariadb или mysql    (https://www.mysql.com/)
#              pciutils             (требуется для сборки qtwebengine)
#              postgresql
#              python2              (требуется для сборки qtwebengine)
#              pulseaudio
#              sdl2
#              unixodbc
#              assimp               (https://www.assimp.org/)
#              flite                (http://www.festvox.org/flite/)
#              firebird             (http://www.firebirdsql.org/)
#              freetds              (http://www.freetds.org/)
#              libproxy             (https://libproxy.github.io/libproxy/)
#              openal               (https://openal.org/)
#              speech-dispatcher    (https://freebsoft.org/speechd/)
#              tslib                (http://www.tslib.org/)
#              vulkan               (https://vulkan.lunarg.com/sdk/home/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

# удаляем пакет qt5, если он уже установлен в системе
INSTALLED="$(find /var/log/packages/ -type f -name "qt5-5.*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${INSTALLED_VERSION} already installed. Before building Qt5 "
    echo "package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"

# NOTE:
# Qt5 рекомендуется устанавливать в каталог, отличный от /usr, поэтому будем
# устанавливать в /opt/qt5-${VERSION}
export QT5PREFIX=/opt/${PRGNAME}-${VERSION}

PIXMAPS="/usr/share/pixmaps"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"/{etc/{profile.d,sudoers.d},usr/bin}
mkdir -pv "${TMP_DIR}"{"${QT5PREFIX}","${PIXMAPS}","${APPLICATIONS}"}

# создаем ссылку в /opt
#    qt5 -> qt5-${VERSION}
ln -sv "${PRGNAME}-${VERSION}" "${TMP_DIR}${QT5PREFIX}/../${PRGNAME}"

./configure                                   \
    -prefix "${QT5PREFIX}"                    \
    -release                                  \
    -sysconfdir "/etc/xdg"                    \
    -confirm-license                          \
    -opensource                               \
    -dbus-linked                              \
    -openssl-linked                           \
    -system-harfbuzz                          \
    -system-libpng                            \
    -system-libjpeg                           \
    -system-zlib                              \
    -system-sqlite                            \
    -accessibility                            \
    -glib                                     \
    -xcb                                      \
    -qpa xcb                                  \
    -icu                                      \
    -no-separate-debug-info                   \
    -reduce-relocations                       \
    -nomake examples                          \
    -strip                                    \
    -no-rpath                                 \
    -skip qtwebengine || exit 1

make || exit 1
# пакет не имеет набора тестов
make install INSTALL_ROOT="${TMP_DIR}"

# удалим ссылки на каталог сборки из установленных библиотек
#    /opt/qt5/lib/libQt5Purchasing.prl
#    /opt/qt5/lib/libQt5MultimediaQuick.prl
#    ...
find "${TMP_DIR}${QT5PREFIX}"/ -name "*.prl" \
    -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;

# устанавливаем .desktop и .png файлы в /usr/share/{applications,pixmaps}
QT5BINDIR="${QT5PREFIX}/bin"
install -v -Dm644                                            \
    qttools/src/assistant/assistant/images/assistant-128.png \
    "${TMP_DIR}${PIXMAPS}/assistant-qt5.png"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/assistant-qt5.desktop"
[Desktop Entry]
Name=Qt5 Assistant
Comment=Shows Qt5 documentation and examples
Exec=${QT5BINDIR}/assistant
Icon=assistant-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

install -v -Dm644                                         \
    qttools/src/designer/src/designer/images/designer.png \
    "${TMP_DIR}${PIXMAPS}/designer-qt5.png"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/designer-qt5.desktop"
[Desktop Entry]
Name=Qt5 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt5 applications
Exec=${QT5BINDIR}/designer
Icon=designer-qt5.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

install -v -Dm644                                                  \
    qttools/src/linguist/linguist/images/icons/linguist-128-32.png \
    "${TMP_DIR}${PIXMAPS}/linguist-qt5.png"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/linguist-qt5.desktop"
[Desktop Entry]
Name=Qt5 Linguist
Comment=Add translations to Qt5 applications
Exec=${QT5BINDIR}/linguist
Icon=linguist-qt5.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

install -v -Dm644                                            \
    qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png \
    "${TMP_DIR}${PIXMAPS}/qdbusviewer-qt5.png"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/qdbusviewer-qt5.desktop"
[Desktop Entry]
Name=Qt5 QDbusViewer
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=${QT5BINDIR}/qdbusviewer
Icon=qdbusviewer-qt5.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

# некоторые пакеты, например vlc, ищут определенные исполняемые файлы в
# /usr/bin с суффиксом -qt5, поэтому создадим необходимые ссылки
#    /usr/bin/qmake-qt5 -> /opt/qt5-${VERSION}/bin/qmake
#    /usr/bin/moc-qt5   -> /opt/qt5-${VERSION}/bin/moc
#    ...
for FILE in moc uic rcc qmake lconvert lrelease lupdate; do
    ln -sfv "../..${QT5BINDIR}/${FILE}" \
        "${TMP_DIR}/usr/bin/${FILE}-${PRGNAME}"
done

QT5_SH="/etc/profile.d/qt5.sh"
cat << EOF > "${TMP_DIR}${QT5_SH}"
# Begin ${QT5_SH}

QT5DIR=/opt/qt5

PATH="\${PATH}:\${QT5DIR}/bin"
PKG_CONFIG_PATH="\${PKG_CONFIG_PATH}:\${QT5DIR}/lib/pkgconfig"

export QT5DIR PATH PKG_CONFIG_PATH

# End ${QT5_SH}
EOF
chmod 755 "${TMP_DIR}${QT5_SH}"

cat << EOF > "${TMP_DIR}/etc/sudoers.d/qt"
Defaults env_keep += QT5DIR
EOF

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
# Home page: http://qt-project.org/
# Download:  https://download.qt.io/archive/qt/${MAJ_VERSION}/${VERSION}/single/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
