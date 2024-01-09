#! /bin/bash

PRGNAME="cairo"

### Cairo (graphics library used by GTK+)
# Библиотека для отрисовки векторной графики с открытым исходным кодом.
# Включает в себя аппаратно-независимый прикладной программный интерфейс для
# разработчиков программного обеспечения. Cairo предоставляет графические
# примитивы для отрисовки двумерных изображений посредством разнообразных
# бекендов. Когда есть возможность, Cairo использует аппаратное ускорение.

# Required:    libpng
#              pixman
# Recommended: fontconfig
#              glib
#              xorg-libraries
# Optional:    cogl
#              ghostscript
#              gtk+3
#              gtk+2
#              gtk-doc
#              libdrm
#              librsvg
#              libxml2
#              lzo
#              mesa
#              poppler
#              qt5
#              valgrind
#              directfb    (https://src.fedoraproject.org/repo/pkgs/directfb/)
#              jbig2dec    (https://github.com/rillian/jbig2dec/)
#              libspectre  (https://www.freedesktop.org/wiki/Software/libspectre/)
#              skia        (https://skia.org/)
#              qt4         (https://download.qt.io/archive/qt/4.8/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# адаптируем пакет для binutils версии 2.39 и более
sed 's/PTR/void */' -i util/cairo-trace/lookup-symbol.c || exit 1

# исправим pkg-config, который в последствии может вызывать ошибки
sed -e "/@prefix@/a exec_prefix=@exec_prefix@" \
    -i util/cairo-script/cairo-script-interpreter.pc.in || exit 1

GTK_DOC="no"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="yes"

# включаем экспериментальный бэкэнд, который требуется при использовании Cairo,
# установленного в системе, с приложениями Mozilla
#    --enable-tee
./configure          \
    --prefix=/usr    \
    --disable-static \
    --enable-tee     \
    --enable-gtk-doc="${GTK_DOC}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (graphics library used by GTK+)
#
# Cairo is a vector graphics library designed to provide high-quality display
# and print output. Cairo is designed to produce identical output on all output
# media while taking advantage of display hardware acceleration when available
# (eg. through the X Render Extension or OpenGL).
#
# Home page: https://www.cairographics.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
