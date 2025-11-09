#! /bin/bash

PRGNAME="gimp"

### Gimp (The GNU Image Manipulation Program)
# Мощный инструмент для обработки цифровых изображений. GIMP предоставляет
# пользователю широкий выбор инструментов для работы с изображениями,
# рисования, обработки и рендеринга. Открытая и расширяемая архитектура GIMP
# делают его очень удобным инструментом для ретуши фотографий и изображений,
# веб-графики, дизайна или цифровой иллюстрации.

# Required:    appstream-glib
#              gegl
#              gexiv2
#              glib-networking
#              gtk+3
#              harfbuzz
#              libmypaint
#              librsvg
#              libtiff
#              libxml2
#              lcms2
#              mypaint-brushes
#              poppler
# Recommended: graphviz
#              ghostscript
#              iso-codes
#              libgudev
#              python3-pygobject3
#              xdg-utils
# Optional:    aalib
#              alsa-lib
#              appstream            (для одного теста)
#              python3-gi-docgen
#              gjs
#              libjxl
#              libmng
#              libunwind
#              libwebp
#              lua
#              openjpeg
#              cfitsio              (https://github.com/HEASARC/cfitsio)
#              libbacktrace         (https://github.com/ianlancetaylor/libbacktrace)
#              libiff               (https://github.com/svanderburg/libiff)
#              libilbm              (https://github.com/svanderburg/libilbm)
#              libheif              (https://github.com/strukturag/libheif/)
#              libde265             (https://github.com/strukturag/libde265/)
#              libwmf               (https://wvware.sourceforge.net/libwmf.html)
#              openexr              (https://www.openexr.com/)
#              qoi                  (https://github.com/phoboslab/qoi)
#              --- для создания справочной системы ---
#              dblatex              (https://dblatex.sourceforge.net/)
#              pngnq                (https://pngnq.sourceforge.net/)
#              pngcrush             (https://pmt.sourceforge.io/pngcrush/)

### Конфиги:
# /etc/gimp/3.x/*

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# при обновлении с предыдущей версии удалим некоторые файлы и каталоги из
# старой установки, иначе система сборки может ошибочно их подобрать, что
# приведет к сбою
rm -rf /usr/{lib,share}/gimp/3.0
rm -f  /usr/share/gir-1.0/Gimp-3.0.gir
rm -f  /usr/lib/girepository-1.0/Gimp-3.0.typelib
rm -f  /usr/lib/libgimp*-3.0.so*

mkdir gimp-build
cd gimp-build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D headless-tests=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш иконок и базу desktop-файлов
#    /usr/share/icons/hicolor/index.theme
#    /usr/share/applications/mimeinfo.cache
gtk-update-icon-cache -qtf /usr/share/icons/hicolor
update-desktop-database -q

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The GNU Image Manipulation Program)
#
# The GIMP is a powerful tool for the preparation and manipulation of digital
# images. The GIMP provides the user with a wide variety of image manipulation,
# painting, processing, and rendering tools. The GIMP's open design and
# extensible architecture make for a very powerful end product for photo and
# image retouching, web graphics design, or digital illustration.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://download.${PRGNAME}.org/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
