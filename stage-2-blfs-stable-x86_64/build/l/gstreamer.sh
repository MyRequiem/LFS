#! /bin/bash

PRGNAME="gstreamer"

### GStreamer (streaming multimedia framework)
# Мультимедийный фреймворк, использующий систему типов GObject. GStreamer
# является "ядром" мультимедийных приложений, таких, как видеоредакторы,
# потоковые серверы и медиапроигрыватели.

# Required:    glib
# Recommended: gobject-introspection
# Optional:    gtk+3           (для генерации примеров)
#              gsl             (для одного из тестов)
#              libunwind
#              valgrind
#              bash-completion (https://github.com/scop/bash-completion/)
#              python3-hotdoc  (https://pypi.org/project/hotdoc/)
#              libdw           (https://sourceware.org/elfutils/)

### NOTE:
# Если мы обновляем пакет, то сначала нужно удалить пакеты:
#    - gstreamer
#    - phonon-backend-gstreamer
#    - gst-plugins-base
#    - gst-plugins-good
#    - gst-plugins-bad
#    - gst-plugins-ugly
#    - clutter-gst
#    - gst-libav
#    - gstreamer-vaapi
# а затем заново их пересобрать

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

EXAMPLES="disabled"
DOCS="disabled"

mkdir build
cd build || exit 1

meson                                          \
    --prefix=/usr                              \
    --buildtype=release                        \
    -Dgst_debug=false                          \
    -Dexamples="${EXAMPLES}"                   \
    -Ddoc="${DOCS}"                            \
    -Dpackage-name="GStreamer ${VERSION} BLFS" \
    -Dpackage-origin="https://www.linuxfromscratch.org/blfs/view/12.2/" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (streaming multimedia framework)
#
# GStreamer is a streaming media framework that enables applications to share a
# common set of plugins for tasks such as video encoding and decoding, audio
# encoding and decoding, audio and video filters, audio visualisation, web
# streaming and anything else that streams in real-time or otherwise. This
# package only provides base functionality and libraries. You may need at least
# gst-plugins-base and one of Good, Bad, Ugly or Libav plugins.
#
# Home page: https://${PRGNAME}.freedesktop.org/
# Download:  https://${PRGNAME}.freedesktop.org/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
