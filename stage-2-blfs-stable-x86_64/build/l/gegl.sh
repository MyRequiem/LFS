#! /bin/bash

PRGNAME="gegl"

### GEGL (Generic Graphics Library)
# Фреймворк для обработки изображений, который задуман как основа GIMP нового
# поколения. Через babl поддерживает широкий спектр цветовых моделей и форматов
# хранения пикселей для ввода и вывода.

# Required:    babl
#              json-glib
# Recommended: gobject-introspection
#              graphviz
#              python3-pygments
#              python3-pygobject3
# Optional:    python3-asciidoc
#              cairo
#              exiv2
#              ffmpeg
#              gdk-pixbuf
#              gexiv2
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
#              lensfun       (https://lensfun.github.io/)
#              libopenraw    (https://libopenraw.pages.freedesktop.org/)
#              libspiro      (http://libspiro.sourceforge.net/)
#              libumfpack    (https://people.engr.tamu.edu/davis/suitesparse.html)
#              luajit        (http://luajit.org/luajit.html)
#              mrg           (https://github.com/hodefoting/mrg/releases)
#              openexr       (https://www.openexr.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="false"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"

# настроим некоторые тестовые сценарии для использования с Python 3, вместо
# Python 2
sed '1s@python@&3@' -i tests/python/*.py

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    -Ddocs="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
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
