#! /bin/bash

PRGNAME="gst-plugins-base"

### GStreamer Base Plugins (base set of GStreamer plugins)
# Плагины GStreamer Base - это хорошо поддерживаемая коллекция подключаемых
# модулей и элементов GStreamer. Включает в себя широкий выбор видео и аудио
# кодеков, декодеров и фильтров.

# Required:    gstreamer
# Recommended: alsa-lib
#              cdparanoia-III (для сборки cdda плагина)
#              gobject-introspection
#              iso-codes
#              libgudev
#              libogg
#              libtheora
#              libvorbis
#              mesa
#              wayland-protocols
#              xorg-libraries
# Optional:    graphene
#              gtk+3
#              opus
#              qt5
#              sdl
#              sdl2
#              valgrind
#              hotdoc    (https://pypi.org/project/hotdoc/)
#              libvisual (http://libvisual.org/)
#              orc       (https://gstreamer.freedesktop.org/src/orc/)
#              tremor    (https://wiki.xiph.org/Tremor)

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
    --wrap-mode=nodownload                     \
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
