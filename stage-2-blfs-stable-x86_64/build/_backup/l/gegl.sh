#! /bin/bash

PRGNAME="gegl"

### gegl (Generic Graphics Library)
# Библиотека и среда обработки изображений. Через Babl обеспечивает поддержку
# для широкого выбора цветовых моделей и форматов хранения пикселей для ввода и
# вывода.

# http://www.linuxfromscratch.org/blfs/view/stable/general/gegl.html

# Home page: http://www.gegl.org/
# Download:  https://download.gimp.org/pub/gegl/0.4/gegl-0.4.22.tar.xz

# Required:    babl
#              json-glib
# Recommended: gobject-introspection
#              python3-pygments
#              python-pygobject3
# Optional:    asciidoc
#              cairo
#              exiv2
#              ffmpeg
#              gdk-pixbuf
#              gexiv2
#              graphviz
#              gtk-doc
#              jasper
#              lcms2
#              libjpeg-turbo
#              libpng
#              librsvg
#              libtiff
#              libwebp
#              pango
#              ruby
#              sdl2
#              v4l-utils
#              vala
#              lensfun    https://lensfun.github.io/
#              libopenraw https://libopenraw.pages.freedesktop.org/
#              libspiro   http://libspiro.sourceforge.net/
#              libumfpack http://faculty.cse.tamu.edu/davis/suitesparse.html
#              luajit     http://luajit.org/luajit.html
#              mrg        https://github.com/hodefoting/mrg/releases
#              openexr    https://www.openexr.com/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd    build || exit 1

GTK_DOC="false"
ASCIIDOC="false"

command -v gtkdoc-check &>/dev/null && GTK_DOC="true"
command -v asciidoc     &>/dev/null && ASCIIDOC="true"

meson                      \
    --prefix=/usr          \
    -Ddocs="${GTK_DOC}"    \
    -Dasciidoc=${ASCIIDOC} \
    .. || exit 1

ninja || exit 1
# ninja test
ninja install
DESTDIR="${TMP_DIR}" ninja install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Generic Graphics Library)
#
# GEGL (Generic Graphics Library) is a graph based image processing framework.
# GEGL provides infrastructure to do demand based cached non destructive image
# editing on larger than RAM buffers. Through babl it provides support for a
# wide range of color models and pixel storage formats for input and output.
#
# Home page: http://www.gegl.org/
# Download:  https://download.gimp.org/pub/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
