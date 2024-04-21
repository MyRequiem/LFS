#! /bin/bash

PRGNAME="gegl"

### GEGL (Generic Graphics Library)
# Фреймворк для обработки изображений, который задуман как основа GIMP нового
# поколения. Через babl поддерживает широкий спектр цветовых моделей и форматов
# хранения пикселей для ввода и вывода.

# Required:    babl
#              json-glib
#              libjpeg-turbo
#              libpng
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
#              libraw
#              librsvg
#              libtiff
#              libwebp
#              pango
#              poppler
#              ruby
#              sdl2
#              v4l-utils
#              vala
#              libspiro
#              lensfun       (https://lensfun.github.io/)
#              libumfpack    (https://people.engr.tamu.edu/davis/suitesparse.html)
#              luajit        (https://luajit.org/luajit.html)
#              opencl        (https://www.khronos.org/opencl/) для тестов
#              mrg           (https://github.com/hodefoting/mrg/releases)
#              openexr       (https://www.openexr.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"

# при обновлении пакета на более позднюю версию, необходимо удалить библиотеку
# vector-fill.so
rm -f "/usr/lib/${PRGNAME}-${MAJ_VERSION}/vector-fill.so"

# если установлен libraw >= 0.21.0, сборка завершается сбоем из-за изменения в
# ABI. Исправим проблему:
sed -e '/shot_select/s/params/raw&/' -i operations/external/raw-load.c

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -Ddocs="false" \
    -Dgtk-doc="false" \
    -Dintrospection="auto" \
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
