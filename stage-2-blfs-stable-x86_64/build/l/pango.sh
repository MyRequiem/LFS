#! /bin/bash

PRGNAME="pango"

### Pango (library for layout and rendering of text)
# Библиотека для отрисовки текста и управления шрифтами, которая умеет
# правильно обрабатывать сложные языки и символы. Она отвечает за то, чтобы
# текст выглядел аккуратно, имел нужный размер и корректно отображался в
# графических интерфейсах.

# Required:    fontconfig          (должен быть собран с freetype и harfbuzz)
#              fribidi
#              glib
# Recommended: cairo               (собранный после harfbuzz)
#              xorg-libraries
# Optional:    python3-docutils    (для man-страниц)
#              python3-gi-docgen   (для документации)
#              help2man            (https://www.gnu.org/software/help2man/) для генерации man-страниц
#              libthai             (https://linux.thai.net/projects/libthai)
#              sysprof             (https://wiki.gnome.org/Apps/Sysprof)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# не позволяем meson загружать любые дополнительные зависимости, которые не
# установлены в системе
#    --wrap-mode=nofallback
meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    --wrap-mode=nofallback   \
    -D introspection=enabled \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Home page: https://www.gtk.org/docs/architecture/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
