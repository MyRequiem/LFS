#! /bin/bash

PRGNAME="gst-plugins-bad"

### GStreamer Bad Plug-ins (bad set of GStreamer plugins)
# Набор плагинов, которые не соответствуют требованиям в полной мере. Они могут
# быть близки к хорошему качеству, но им чего-то не хватает, например код не
# всегда хорошо читаем, отсутствует документация, наборы тестов, maintainer или
# что-то другое.

# Required:    gst-plugins-base
# Recommended: libdvdread
#              libdvdnav
#              soundtouch
# Optional:    bluez
#              curl
#              faac
#              faad2
#              fdk-aac
#              gtk+3                (для сборки примеров)
#              gst-plugins-good     (для одного теста)
#              lcms2
#              libass
#              libexif              (для одного теста)
#              librsvg
#              libsoup              (для одного теста)
#              libsndfile
#              libssh2
#              libusb
#              libva
#              libwebp
#              libxkbcommon
#              neon
#              nettle или libgcrypt (для поддержки ssl в плагине hls, если оба не установлены, вместо этого будет использоваться openssl)
#              opencv               (с дополнительными модулями)
#              openjpeg
#              opus
#              sbc
#              sdl
#              valgrind
#              wayland              (gtk+3 должен быть скомпилирован с поддержкой Wayland)
#              wpebackend-fdo
#              x265
#              aom                  (https://aomedia.googlesource.com/aom/)
#              bs2b                 (https://bs2b.sourceforge.net/)
#              chromaprint          (https://acoustid.org/chromaprint)
#              dssim                (https://github.com/kornelski/dssim)
#              flite                (https://github.com/festvox/flite)
#              fluidsynth           (https://www.fluidsynth.org/)
#              game-music-emu       (https://bitbucket.org/mpyne/game-music-emu/)
#              gsm                  (https://www.quut.com/gsm/)
#              python3-hotdoc       (https://pypi.org/project/hotdoc/)
#              ladspa               (https://www.ladspa.org/)
#              libavtp              (https://github.com/AVnu/libavtp)
#              libdc1394_2          (https://sourceforge.net/projects/libdc1394/files/libdc1394-2/)
#              libdca               (https://www.videolan.org/developers/libdca.html)
#              libde265             (https://www.libde265.org/)
#              libkate              (https://code.google.com/archive/p/libkate/)
#              libmfx               (https://github.com/Intel-Media-SDK/MediaSDK)
#              libmms               (https://sourceforge.net/projects/libmms/)
#              libmodplug           (https://github.com/Konstanty/libmodplug)
#              libnice              (https://libnice.freedesktop.org/)
#              libofa               (https://code.google.com/archive/p/musicip-libofa/)
#              libopenmpt           (https://lib.openmpt.org/libopenmpt/)
#              libopenni            (https://structure.io/openni/)
#              libsrtp              (https://github.com/cisco/libsrtp)
#              lilv                 (https://drobilla.net/software/lilv)
#              lrdf                 (https://github.com/swh/LRDF)
#              ltc-tools            (https://github.com/x42/ltc-tools)
#              microdns             (https://github.com/videolabs/libmicrodns)
#              mjpeg-tools          (https://mjpeg.sourceforge.io/)
#              openal               (https://openal.org/)
#              openexr              (https://www.openexr.com/)
#              openh264             (https://www.openh264.org/)
#              orc                  (https://gstreamer.freedesktop.org/src/orc/)
#              rtmpdump             (https://rtmpdump.mplayerhq.hu/)
#              spandsp              (https://github.com/jart/spandsp)
#              srt                  (https://github.com/Haivision/srt)
#              svthevcenc           (https://github.com/OpenVisualCloud/SVT-HEVC/)
#              vo-aac               (https://sourceforge.net/projects/opencore-amr/files/vo-aacenc/)
#              vo-amrwb             (https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/)
#              vulkan               (https://vulkan.lunarg.com/sdk/home/)
#              wildmidi             (https://github.com/Mindwerks/wildmidi/)
#              wpe-webkit           (https://webkit.org/wpe/)
#              zbar                 (https://zbar.sourceforge.net/)
#              zvbi                 (https://zapping.sourceforge.net/Zapping/index.html)
#              zxing                (https://github.com/zxing/zxing)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# без этой опции плагины с зависимостями от библиотек под лицензией (A)GPL не
# создаются
#    -Dgpl=enabled
meson                                          \
    --prefix=/usr                              \
    --buildtype=release                        \
    -Dgpl=enabled                              \
    -Dpackage-name="GStreamer ${VERSION} BLFS" \
    -Dpackage-origin=https://www.linuxfromscratch.org/blfs/view/12.2/ || exit 1

ninja || exit 1

# для некоторых тестов нужен эмулятор терминала в графическом сеансе
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (bad set of GStreamer plugins)
#
# GStreamer Bad Plug-ins is a set of plug-ins that aren't up to par compared to
# the rest. They might be close to being good quality, but they're missing
# something - be it a good code review, some documentation, a set of tests, a
# real live maintainer, or some actual wide use.
#
# Home page: https://gstreamer.freedesktop.org/modules/
# Download:  https://gstreamer.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
