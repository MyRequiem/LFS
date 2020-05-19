#! /bin/bash

PRGNAME="graphviz"

### Graphviz (Graph Visualization)
# Программное обеспечение для визуализации графиков в виде диаграмм абстрактных
# графов. Имеет несколько основных программ верстки графов, интерфейс и
# вспомогательные инструменты для веб и интерактивной графики, библиотеки и
# языковые привязки.

# http://www.linuxfromscratch.org/blfs/view/stable/general/graphviz.html

# Home page: https://www.graphviz.org/
# Download:  https://www2.graphviz.org/Packages/stable/portable_source/graphviz-2.42.3.tar.gz

# Required: no
# Optional:
# для создания svg, postscript, png и pdf изображений и отображения изображений
# на экране
#    pango
#    cairo
#    xorg-libraries (так же для сборки графического редактора dotty)
#    fontconfig
#    libpng
#
# добавление форматов jpeg, bmp, tif и ico и для отображения изображений в
# gtk2 окнах
#    gtk+2
#    libjpeg-turbo
#
# может использоваться вместо pango и добавляет возможность генерировать
# изображения в форматах gif, vrml и gd, но pango обеспечивает лучшие
# результаты для других форматов, и необходим именно для отображения
# изображений
#    gd-library (https://libgd.github.io/)
#
# добавление других форматов изображений
#    libwebp
#    devil    (http://openil.sourceforge.net/projects.php)
#    liblasi  (https://sourceforge.net/projects/lasi/)
#    glitz    (http://www.freedesktop.org/wiki/Software/glitz)
#    libming  (Adobe Flash) http://www.libming.org/
#
# для загрузки графических изображений, которые могут отображаться внутри узлов
# графика
#    ghostscript
#    librsvg
#    poppler
#
# для сборки дополнительных утилит
#    freeglut
#    libglade
#    gtkglext (https://projects.gnome.org/gtkglext/)
#    libgts   (для сборки утилиты просмотра графов smyrna) http://gts.sourceforge.net/
#    qt5      (для сборки графического редактора gvedit)
#
# для построения языковых привязок (language bindings)
#    swig
#    gcc     (с возможностью компиляции кода на языке go)
#    guile
#    openjdk
#    lua53
#    php
#    python2
#    ruby
#    tcl
#    tk
#    io      (http://iolanguage.org/)
#    mono    (https://www.mono-project.com/)
#    ocaml   (https://ocaml.org/)
#    r       (https://www.r-project.org/)
#
# инструменты сборки
#    criterion       (framework для тестов) https://github.com/Snaipe/Criterion
#    electric-fence  (https://linux.softpedia.com/get/Programming/Debuggers/Electric-Fence-3305.shtml/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc"
mkdir -pv "${TMP_DIR}${DOCS}"

# избегаем установки библиотек в /usr/lib64
sed -i '/LIBPOSTFIX="64"/s/64//' configure.ac &&

IO="--disable-io"
LIBWEBP="--without-webp"
GLITZ="--without-glitz"
LIBMING="--without-ming"
OPENJDK=""

command -v io     &>/dev/null && IO="--enable-io"
command -v cwebp  &>/dev/null && LIBWEBP="--with-webp"
[ -x /usr/lib/libglitz.so.1 ] && GLITZ="--with-glitz"
[ -x /usr/lib/libming.so.1 ]  && LIBMING="--with-ming"

[ -n "${JAVA_HOME}" ] && \
    OPENJDK_INCLUDE="${JAVA_HOME}/include -I${JAVA_HOME}/include/linux" && \
    OPENJDK="--with-javaincludedir=${OPENJDK_INCLUDE}"

autoreconf &&     \
./configure       \
    --prefix=/usr \
    --with-smyrna \
    "${IO}"       \
    "${LIBWEBP}"  \
    "${GLITZ}"    \
    "${LIBMING}"  \
    "${OPENJDK}" || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/share/doc на документацию, которая уже установлена в
# /usr/share/graphviz/doc
(
    cd "${DOCS}" || exit 1
    rm -f "${PRGNAME}-${VERSION}"
    ln -svf ../graphviz/doc "${PRGNAME}-${VERSION}"
    cd "${TMP_DIR}${DOCS}" || exit 1
    ln -svf ../graphviz/doc "${PRGNAME}-${VERSION}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Graph Visualization)
#
# Graphviz is open source graph visualization software. It has several main
# graph layout programs. It also has web and interactive graphical interfaces,
# and auxiliary tools, libraries, and language bindings.
#
# Home page: https://www.graphviz.org/
# Download:  https://www2.graphviz.org/Packages/stable/portable_source/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
