#! /bin/bash

PRGNAME="qt6"
ARCH_NAME="qt-everywhere-src"

### Qt (a multi-platform C++ graphical user interface toolkit)
# Самая современная версия графического фреймворка, на котором строятся
# интерфейсы будущего. Она предлагает улучшенную скорость работы, поддержку
# новейших видеокарт и современные инструменты для создания красивых программ.
# Одним из основных пользователей Qt является KDE Frameworks 6 (KF6)

# Required:    xorg-libraries
# Recommended: alsa-lib
#              make-ca
#              libcups или cups
#              dbus
#              double-conversion
#              glib
#              ffmpeg                       (для qtmultimedia backend)
#              gst-plugins-base             (для qtmultimedia backend)
#              gst-plugins-good             (для qtmultimedia backend)
#              gst-plugins-bad              (для qtmultimedia backend)
#              harfbuzz
#              icu
#              jasper
#              libjpeg-turbo
#              libinput
#              libmng
#              libpng
#              libtiff
#              libwebp
#              libxkbcommon
#              mesa
#              mtdev
#              wayland
#              xcb-util-cursor
#              xcb-util-image
#              xcb-util-keysyms
#              xcb-util-renderutil
#              xcb-util-wm
# Optional:    bluez
#              gtk+3
#              ibus
#              llvm
#              libproxy
#              mariadb или mysql            (https://www.mysql.com/)
#              mit-kerberos-v5
#              pciutils
#              postgresql
#              protobuf
#              pulseaudio
#              sdl2-compat
#              unixodbc
#              assimp                       (https://www.assimp.org/)
#              flite                        (https://github.com/festvox/flite)
#              firebird                     (https://www.firebirdsql.org/)
#              freetds                      (https://www.freetds.org/)
#              openal                       (https://openal.org/)
#              speech-dispatcher            (https://freebsoft.org/speechd/)
#              tslib                        (http://www.tslib.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

# для сборки версии 6.11.0 требуется ~60Gb дискового пространства (~59Gb сборка
# и ~550M сам пакет), поэтому собираем не в разделе /tmp (30Gb), а в разделе
# где хватает места
BUILD_DIR="/home/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"

# NOTE:
# Qt6 рекомендуется устанавливать в каталог, отличный от /usr, поэтому будем
# устанавливать в /opt/${PRGNAME}-${VERSION}
export QT6PREFIX="/opt/${PRGNAME}-${VERSION}"

mkdir -pv "${TMP_DIR}/etc"/{profile.d,sudoers.d,ld.so.conf.d}
mkdir -pv "${TMP_DIR}${QT6PREFIX}"

./configure                \
    -prefix "${QT6PREFIX}" \
    -sysconfdir /etc/xdg   \
    -dbus-linked           \
    -openssl-linked        \
    -system-sqlite         \
    -nomake examples       \
    -no-rpath              \
    -no-sbom               \
    -syslog                \
    -skip qt3d             \
    -skip qtquick3dphysics \
    -skip qtwebengine || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

# удалим ссылки на каталог сборки из установленных библиотек
#    /opt/${PRGNAME}/lib/libQt6Purchasing.prl
#    /opt/${PRGNAME}/lib/libQt6MultimediaQuick.prl
#    ...
find "${TMP_DIR}${QT6PREFIX}"/ -name \*.prl \
   -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \+

PIXMAPS="/usr/share/pixmaps"
mkdir -p "${TMP_DIR}${PIXMAPS}"

pushd qttools/src || exit 1
install -v -Dm644 assistant/assistant/images/assistant-128.png       \
    "${TMP_DIR}${PIXMAPS}/assistant-${PRGNAME}.png"                  &&
install -v -Dm644 designer/src/designer/images/designer.png          \
    "${TMP_DIR}${PIXMAPS}/designer-${PRGNAME}.png"                   &&
install -v -Dm644 linguist/linguist/images/icons/linguist-128-32.png \
    "${TMP_DIR}${PIXMAPS}/linguist-${PRGNAME}.png"                   &&
install -v -Dm644 qdbus/qdbusviewer/images/qdbusviewer-128.png       \
    "${TMP_DIR}${PIXMAPS}/qdbusviewer-${PRGNAME}.png"                &&
popd || exit 1

APPLICATIONS="/usr/share/applications"
mkdir -p "${TMP_DIR}${APPLICATIONS}"

cat << EOF > "${TMP_DIR}${APPLICATIONS}/assistant-${PRGNAME}.desktop"
[Desktop Entry]
Name=Qt6 Assistant
Comment=Shows Qt6 documentation and examples
Exec=${QT6PREFIX}/bin/assistant
Icon=assistant-${PRGNAME}.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

cat << EOF > "${TMP_DIR}${APPLICATIONS}/designer-${PRGNAME}.desktop"
[Desktop Entry]
Name=Qt6 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt6 applications
Exec=${QT6PREFIX}/bin/designer
Icon=designer-${PRGNAME}.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat << EOF > "${TMP_DIR}${APPLICATIONS}/linguist-${PRGNAME}.desktop"
[Desktop Entry]
Name=Qt6 Linguist
Comment=Add translations to Qt6 applications
Exec=${QT6PREFIX}/bin/linguist
Icon=linguist-${PRGNAME}.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat << EOF > "${TMP_DIR}${APPLICATIONS}/qdbusviewer-${PRGNAME}.desktop"
[Desktop Entry]
Name=Qt6 QDbusViewer
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=${QT6PREFIX}/bin/qdbusviewer
Icon=qdbusviewer-${PRGNAME}.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

# QT6DIR также должен быть доступен пользователю root
SUDOERS="/etc/sudoers.d/${PRGNAME}"
cat > "${TMP_DIR}${SUDOERS}" << "EOF"
Defaults env_keep += QT6DIR
EOF
chmod 440 "${TMP_DIR}${SUDOERS}"

# добавим путь поиска библиотек для динамического загрузчика
cat << EOF > "${TMP_DIR}/etc/ld.so.conf.d/${PRGNAME}.conf"
${QT6PREFIX}/lib
EOF

QT6_SH="/etc/profile.d/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${QT6_SH}"
# Begin ${QT6_SH}

QT6DIR=${QT6PREFIX}

PATH="\${PATH}:\${QT6DIR}/bin"
PKG_CONFIG_PATH="\${PKG_CONFIG_PATH}:\${QT6DIR}/lib/pkgconfig"
QT_PLUGIN_PATH=\${QT6DIR}/plugins
QML2_IMPORT_PATH=\${QT6DIR}/qml

export QT6DIR PATH PKG_CONFIG_PATH QT_PLUGIN_PATH QML2_IMPORT_PATH

# End ${QT6_SH}
EOF
chmod 755 "${TMP_DIR}${QT6_SH}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш динамического загрузчика
ldconfig

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a multi-platform C++ graphical user interface toolkit)
#
# Qt6 is a cross-platform C++ application framework that is widely used for
# developing application software with a graphical user interface (GUI) (in
# which cases Qt6 is classified as a widget toolkit), and also used for
# developing non-GUI programs such as command-line tools and consoles for
# servers. One of the major users of Qt is KDE Frameworks 6 (KF6).
#
# Home page: https://qt-project.org/
# Download:  https://download.qt.io/archive/qt/${MAJ_VERSION}/${VERSION}/single/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
