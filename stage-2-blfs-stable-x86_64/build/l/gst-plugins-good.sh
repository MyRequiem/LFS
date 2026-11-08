#! /bin/bash

PRGNAME="gst-plugins-good"

### GStreamer Good Plug-ins (good set of GStreamer plugins)
# Коллекция высококачественных и свободных плагинов для GStreamer, которые
# отвечают за поддержку популярных форматов и эффектов без лицензионных
# проблем. В этот набор входят проверенные временем инструменты для работы с
# видеокамерами, звуком и форматами вроде FLAC, JPEG и AVI.

# Required:    gst-plugins-base
# Recommended: cairo
#              flac
#              gdk-pixbuf
#              lame
#              libsoup3
#              libvpx
#              mpg123            (библиотека libmpg123.so - декодирование MP3)
#              nasm
#              pulseaudio
# Optional:    aalib
#              gtk+3             (для сборки примеров)
#              qt6               (для сборки libgstqml6.so и libgstqmlgl.so - нужны только для стриминга GStreamer+QML, плейерам vlc, mpv они не нужны)
#              taglib
#              v4l-utils
#              libsoup2
#              orc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..             \
    --prefix=/usr          \
    --buildtype=release    \
    -D qt-wayland=disabled \
    -D examples=disabled   \
    -D doc=disabled        \
    -D tests=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
