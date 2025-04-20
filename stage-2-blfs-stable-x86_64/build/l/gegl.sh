#! /bin/bash

PRGNAME="gegl"

### GEGL (Generic Graphics Library)
# Фреймворк для обработки изображений, который задуман как основа GIMP нового
# поколения. Через babl поддерживает широкий спектр цветовых моделей и форматов
# хранения пикселей для ввода и вывода.

# Required:    babl
#              json-glib
# Recommended: glib
#              graphviz
#              python3-pygments
#              python3-pygobject3
# Optional:    python3-asciidoc
#              cairo
#              ffmpeg
#              gdk-pixbuf
#              gexiv2
#              gtk-doc
#              jasper
#              lcms2
#              libraw
#              librsvg
#              libspiro
#              libtiff
#              libwebp
#              pango
#              poppler
#              ruby
#              sdl2
#              v4l-utils
#              vala
#              luajit              (https://luajit.org/luajit.html)
#              lensfun             (https://lensfun.github.io/)
#              libnsgif            (https://www.netsurf-browser.org/projects/libnsgif/)
#              libumfpack          (https://people.engr.tamu.edu/davis/suitesparse.html)
#              maxflow             (https://github.com/gerddie/maxflow)
#              mrg                 (https://github.com/hodefoting/mrg/releases)
#              opencl              (https://www.khronos.org/opencl/) для тестов
#              openexr             (https://www.openexr.com/)
#              poly2tri-c          (https://github.com/KyleLink/poly2tri-c)
#              source-highlight    (https://www.gnu.org/software/src-highlite/)
#              w3m                 (https://w3m.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"

# при обновлении пакета на более позднюю версию, необходимо удалить библиотеку
# vector-fill.so
rm -f "/usr/lib/${PRGNAME}-${MAJ_VERSION}/vector-fill.so"

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -D libav=disabled   \
    -D docs="false"     \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Generic Graphics Library)
#
# GEGL (Generic Graphics Library) is a graph based image processing framework.
# GEGL provides infrastructure to do demand based cached non destructive image
# editing on larger than RAM buffers. Through babl it provides support for a
# wide range of color models and pixel storage formats for input and output.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://download.gimp.org/pub/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
