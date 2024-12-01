#! /bin/bash

PRGNAME="pango"

### Pango (library for layout and rendering of text)
# Библиотека для отображения текста на разных языках в высоком качестве.
# Поддерживает три различных способа отображения шрифтов, благодаря чему
# работает во многих операционных системах и является основой обработки текста
# и шрифтов в GTK+2

# Required:    fontconfig (должен быть собран с freetype и harfbuzz)
#              fribidi
#              glib
# Recommended: cairo
#              xorg-libraries
# Optional:    cantarell-font-otf    (для тестов)
#              sysprof
#              python3-gi-docgen     (для генерации документации)
#              help2man              (https://www.gnu.org/software/help2man/) для генерации man-страниц
#              libthai               (https://linux.thai.net/projects/libthai)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

GTK_DOC="false"
# command -v gi-docgen &>/dev/null && GTK_DOC="true"

# не позволяем meson загружать любые дополнительные зависимости, которые не
# установлены в системе
#    --wrap-mode=nofallback
meson                      \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    -Dgtk_doc="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for layout and rendering of text)
#
# Pango is a library for layout and rendering of text, with an emphasis on
# internationalization. Pango can be used anywhere that text layout is needed;
# however, most of the work on Pango was done using the GTK+ widget toolkit as
# a test platform. Pango forms the core of text and font handling for GTK+-2.
#
# Home page: https://pango.gnome.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
