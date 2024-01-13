#! /bin/bash

PRGNAME="gimp"

### Gimp (The GNU Image Manipulation Program)
# Мощный инструмент для обработки цифровых изображений. GIMP предоставляет
# пользователю широкий выбор инструментов для работы с изображениями,
# рисования, обработки и рендеринга. Открытая и расширяемая архитектура GIMP
# делают его очень удобным инструментом для ретуши фотографий и изображений,
# веб-графики, дизайна или цифровой иллюстрации.

# Required:    gegl
#              gexiv2
#              glib-networking
#              gtk+3
#              harfbuzz
#              libjpeg-turbo
#              libmypaint
#              librsvg
#              libtiff
#              python2-libxml2
#              lcms2
#              mypaint-brushes
#              poppler
#              Graphical Environments
# Recommended: dbus-glib
#              ghostscript
#              gvfs
#              iso-codes
#              libgudev
#              python2-pygtk
#              xdg-utils
# Optional:    aalib
#              alsa-lib
#              libmng
#              libunwind
#              libwebp
#              openjpeg
#              dovecot или exim или postfix или sendmail
#              gtk-doc
#              appstream-glib (https://people.freedesktop.org/~hughsient/appstream-glib/)
#              libbacktrace   (https://github.com/ianlancetaylor/libbacktrace)
#              libheif        (https://github.com/strukturag/libheif/)
#              libde265       (https://github.com/strukturag/libde265/)
#              libwmf         (http://wvware.sourceforge.net/libwmf.html)

### Конфиги:
# /etc/gimp/2.x/*
# ~/.gimp-2.x/gimprc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1

# тесты требуют запущенной X-сессии
# make check

make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим кэш иконок и базу desktop-файлов
#    /usr/share/icons/hicolor/index.theme
#    /usr/share/applications/mimeinfo.cache
gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
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
# Download:  https://download.${PRGNAME}.org/pub/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
