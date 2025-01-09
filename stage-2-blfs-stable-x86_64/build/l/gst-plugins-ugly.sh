#! /bin/bash

PRGNAME="gst-plugins-ugly"

### GStreamer Ugly Plug-ins (ugly set of GStreamer plugins)
# Набор GStreamer плагинов хорошего качества и правильной функциональности, но
# их распространение может вызвать проблемы. Лицензия на подключаемые модули
# или поддерживающие библиотеки может быть не такой как нам нравится.

# Required:    gst-plugins-base
# Recommended: liba52            (для проигрывания DVD)
#              libdvdread
#              x264
# Optional:    libmpeg2
#              libcdio           (для доступа к CD-ROM)
#              valgrind
#              python3-hotdoc    (https://pypi.org/project/hotdoc/)
#              libsidplay        (https://packages.debian.org/source/sid/libsidplay)
#              orc               (https://gstreamer.freedesktop.org/src/orc/)

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
meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D gpl=enabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ugly set of GStreamer plugins)
#
# GStreamer Ugly Plug-ins is a set of plug-ins that have good quality and
# correct functionality, but distributing them might pose problems. The license
# on either the plug-ins or the supporting libraries might not be how we' like.
# The code might be widely known to present patent problems.
#
# Home page: https://gstreamer.freedesktop.org/modules/
# Download:  https://gstreamer.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
