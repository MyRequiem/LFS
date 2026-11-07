#! /bin/bash

PRGNAME="pipewire"

### PipeWire (multimedia processing)
# Современный мультимедийный сервер нового поколения для управления потоками
# аудио и видео с минимальной задержкой. Он призван объединить и заменить собой
# старые звуковые системы PulseAudio и JACK.

# Required:    no
# Recommended: bluez
#              dbus
#              gstreamer
#              gst-plugins-base
#              pulseaudio
#              sbc
#              v4l-utils
#              wireplumber          (runtime)
# Optional:    alsa-lib
#              avahi
#              fdk-aac
#              ffmpeg
#              libcanberra
#              libdrm
#              libxcb
#              libsndfile
#              libusb
#              opus
#              sdl2-compat
#              valgrind
#              vulkan-loader
#              xorg-libraries
#              doxygen
#              graphviz
#              ffado                (https://ffado.org/)
#              jack                 (https://jackaudio.org/)
#              lc3plus              (https://github.com/arkq/LC3plus)
#              ldacbt               (https://github.com/EHfive/ldacBT)
#              libcamera            (https://libcamera.org/)
#              libmysofa            (https://github.com/hoene/libmysofa)
#              lilv                 (https://drobilla.net/software/lilv.html)
#              xmltoman             (https://sourceforge.net/projects/xmltoman/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D session-managers="[]" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (multimedia processing)
#
# The pipewire package contains a server and userspace API to handle multimedia
# pipelines. This includes a universal API to connect to multimedia devices, as
# well as sharing multimedia files between applications.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
