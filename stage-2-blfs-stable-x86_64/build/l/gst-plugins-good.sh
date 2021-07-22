#! /bin/bash

PRGNAME="gst-plugins-good"

### GStreamer Good Plug-ins (good set of GStreamer plugins)
# Набор подключаемых модулей для GStreamer. Модули имеют хороший качественный
# код и правильный функционал. Содержит широкий спектр видео и аудиодекодеров,
# кодировщиков и фильтров.

# Required:    gst-plugins-base
# Recommended: cairo
#              flac
#              gdk-pixbuf
#              lame
#              libgudev
#              libjpeg-turbo
#              libpng
#              libsoup
#              libvpx
#              mesa
#              mpg123
#              nasm
#              xorg-libraries
# Optional:    aalib
#              alsa-oss
#              gtk+3
#              libdv
#              pulseaudio
#              qt5
#              speex
#              taglib
#              valgrind
#              v4l-utils
#              wayland
#              hotdoc      (https://pypi.org/project/hotdoc/)
#              jack        (https://jackaudio.org/)
#              libcaca     (http://caca.zoy.org/wiki/libcaca)
#              libavc1394  (https://sourceforge.net/projects/libavc1394/)
#              libiec61883 (https://sourceforge.net/projects/libraw1394/)
#              libraw1394  (https://sourceforge.net/projects/libraw1394/)
#              libshout    (https://www.icecast.org/)
#              orc         (https://gstreamer.freedesktop.org/src/orc/)
#              twolame     (https://www.twolame.org/)
#              wavpack     (https://www.wavpack.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

EXAMPLES="disabled"
DOCS="disabled"
TESTS="disabled"

mkdir build
cd build || exit 1

meson                                          \
    --prefix=/usr                              \
    -Dexamples="${EXAMPLES}"                   \
    -Ddoc="${DOCS}"                            \
    -Dtests="${TESTS}"                         \
    -Dbuildtype=release                        \
    -Dpackage-name="GStreamer ${VERSION} BLFS" \
    -Dpackage-origin=http://www.linuxfromscratch.org/blfs/view/svn/ || exit 1

ninja || exit 1

### тесты
#    - устанавливаем переменную TESTS выше в 'enabled'
#    - тесты проводятся в графической среде
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (good set of GStreamer plugins)
#
# The GStreamer Good Plug-ins is a set of plug-ins considered by the GStreamer
# developers to have good quality code, correct functionality, and the
# preferred license (LGPL for the plug-in code, LGPL or LGPL-compatible for the
# supporting library). A wide range of video and audio decoders, encoders, and
# filters are included.
#
# Home page: https://gstreamer.freedesktop.org/modules/
# Download:  https://gstreamer.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
