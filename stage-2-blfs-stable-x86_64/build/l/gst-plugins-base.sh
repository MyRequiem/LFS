#! /bin/bash

PRGNAME="gst-plugins-base"

### GStreamer Base Plugins (base set of GStreamer plugins)
# Базовый набор инструментов для мультимедийного движка GStreamer, который
# обеспечивает фундаментальные функции: воспроизведение звука, обработку видео
# и поддержку популярных форматов вроде Ogg или Vorbis. Это обязательный
# «фундамент», без которого большинство программ не смогут даже просто открыть
# аудио- или видеофайл. Включает в себя широкий выбор видео и аудио кодеков,
# декодеров и фильтров.

# Required:    gstreamer
# Recommended: alsa-lib
#              cdparanoia-III         (для сборки cdda плагина)
#              glib
#              iso-codes
#              libgudev
#              libjpeg-turbo
#              libogg
#              libpng
#              libvorbis
#              mesa
#              pango
#              wayland-protocols
#              xorg-libraries
# Optional:    graphene
#              gtk+3                  (для сборки примеров)
#              opus
#              sdl2-compat
#              valgrind
#              python3-hotdoc         (https://pypi.org/project/hotdoc/)
#              libtheora              (https://www.theora.org/)
#              libvisual              (http://libvisual.org/)
#              orc                    (https://gstreamer.freedesktop.org/src/orc/)
#              tremor                 (https://wiki.xiph.org/Tremor)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим нерабочий тест
sed -i '/tcase_add_test (tc_chain, test_reorder_buffer);/d' \
    tests/check/libs/gstglcolorconvert.c || exit 1

mkdir build
cd build || exit 1

# не позволяем мезону загружать любые дополнительные зависимости, которые не
# установлены в системе
#    --wrap-mode=nodownload
meson setup ..             \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nodownload \
    -D examples=disabled   \
    -D doc=disabled        \
    -D tests=disabled || exit 1

ninja || exit 1

# тесты проводятся в графической среде
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (base set of GStreamer plugins)
#
# The GStreamer Base Plug-ins is a well-groomed and well-maintained collection
# of GStreamer plug-ins and elements, spanning the range of possible types of
# elements one would want to write for GStreamer. It also contains helper
# libraries and base classes useful for writing elements. A wide range of video
# and audio decoders, encoders, and filters are included. You will need at
# least one of Good, Bad, Ugly or Libav plugins for GStreamer applications to
# function properly.
#
# Home page: https://gstreamer.freedesktop.org/modules/
# Download:  https://gstreamer.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
