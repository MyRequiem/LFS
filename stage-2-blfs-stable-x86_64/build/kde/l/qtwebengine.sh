#! /bin/bash

PRGNAME="qtwebengine"
ARCH_NAME="qtwebengine-everywhere-src"

### QtWebEngine (integrates chromium's web capabilities into Qt)

# Required:    cups
#              python3-html5lib
#              nodejs
#              nss
#              pciutils
#              qt6
# Recommended: alsa-lib или pulseaudio
#              ffmpeg
#              icu
#              libevent
#              libwebp
#              libxslt
#              opus
#              pipewire
# Optional:    mit-kerberos-v5
#              poppler
#              jsoncpp              (https://github.com/open-source-parsers/jsoncpp/releases)
#              libsrtp              (https://github.com/cisco/libsrtp/releases)
#              snappy               (https://google.github.io/snappy/)

### Конфигурация ядра
#    CONFIG_NAMESPACES=y
#    CONFIG_USER_NS=y
#    CONFIG_PID_NS=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/opt/qt6"

mkdir build
cd build || exit 1

cmake                                             \
    -D CMAKE_MESSAGE_LOG_LEVEL=STATUS             \
    -D QT_FEATURE_webengine_system_ffmpeg=ON      \
    -D QT_FEATURE_webengine_system_icu=ON         \
    -D QT_FEATURE_webengine_system_libevent=ON    \
    -D QT_FEATURE_webengine_proprietary_codecs=ON \
    -D QT_FEATURE_webengine_webrtc_pipewire=ON    \
    -D QT_BUILD_EXAMPLES_BY_DEFAULT=OFF           \
    -D QT_GENERATE_SBOM=OFF                       \
    -G Ninja                                      \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

###
# WARNINIG
###
# Пакет по умолчанию устанавливается с префиксом ${QT6DIR}, т.е. в
# /opt/qt6 - ссылка на директорию qt6-x.x.x
#
# В данном случае пакет установлен в директорию DESTDIR/opt/qt6, поэтому при
# копировании директории DESTDIR/opt/qt6 в корень системы произойдет ошибка,
# т.к. существует ссылка /opt/qt6
#
# Переименуем DESTDIR/opt/qt6 в qt6-x.x.x
REAL_QT6DIR="/opt/$(readlink "${QT6DIR}")"
mv "${TMP_DIR}${QT6DIR}" "${TMP_DIR}${REAL_QT6DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (integrates chromium's web capabilities into Qt)
#
# QtWebEngine integrates chromium's web capabilities into Qt
#
# Home page: https://qt-project.org/
# Download:  https://download.qt.io/official_releases/qt/${MAJ_VERSION}/${VERSION}/submodules/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
