#! /bin/bash

PRGNAME="freerdp"
ARCH_NAME="FreeRDP"
DOCBOOK_XSL_VER="1.79.2"

### FreeRDP (Free Remote Desktop Protocol)
# Свободная (open-source) реализация протокола удаленного рабочего стола
# Microsoft (RDP), позволяющая подключаться к удаленным компьютерам Windows и
# другим совместимым системам, работающая на разных платформах, таких как
# Linux, macOS, Android, iOS, и активно поддерживаемая, в отличие от старого
# rdesktop. Это мощный клиент, поддерживающий современные версии протокола (RDP
# 7.1 и выше), включая сетевую аутентификацию (NLA) для безопасности.

# Required:    ffmpeg
#              icu
#              xorg-libraries
# Recommended: cairo
#              docbook-xsl          (для создания man-страниц)
#              fuse3
#              json-c
#              mit-kerberos-v5
#              libusb
#              libxkbcommon
#              wayland
# Optional:    cups
#              faac
#              faad2
#              fdk-aac
#              lame
#              linux-pam
#              pulseaudio
#              cjson                (https://github.com/DaveGamble/cJSON)
#              gsm                  (https://www.quut.com/gsm/)
#              ocl-icd              (https://github.com/OCL-dev/ocl-icd)
#              mbedtls              (https://github.com/Mbed-TLS/mbedtls)
#              openh264             (https://www.openh264.org/)
#              pcsclite             (https://pcsclite.apdu.fr/)
#              sdl-ttf              (https://github.com/libsdl-org/SDL_ttf)
#              soxr                 (https://github.com/chirlu/soxr)
#              uriparser            (https://github.com/uriparser/uriparser)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

XSL_STYLESHEETS="/usr/share/xml/docbook/xsl-stylesheets-nons-${DOCBOOK_XSL_VER}"
cmake                                      \
    -D CMAKE_INSTALL_PREFIX=/usr           \
    -D CMAKE_SKIP_INSTALL_RPATH=ON         \
    -D CMAKE_BUILD_TYPE=Release            \
    -D WITH_CAIRO=ON                       \
    -D WITH_CLIENT_SDL=OFF                 \
    -D WITH_DSP_FFMPEG=ON                  \
    -D WITH_FFMPEG=ON                      \
    -D WITH_PCSC=OFF                       \
    -D WITH_SERVER=ON                      \
    -D WITH_SERVER_CHANNELS=ON             \
    -D DOCBOOKXSL_DIR="${XSL_STYLESHEETS}" \
    -D WITH_LAME=ON                        \
    -D WITH_FAAD2=ON                       \
    -D WITH_FDK_AAC=ON                     \
    -W no-dev                              \
    -G Ninja                               \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Free Remote Desktop Protocol)
#
# The FreeRDP package contains libraries and utilities for utilizing the Remote
# Desktop Protocol. This includes tools to run an RDP server as well as to
# connect to a computer using RDP. This is primarily used for connecting to
# Microsoft Windows computers, but can also be used on Linux and macOS
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
