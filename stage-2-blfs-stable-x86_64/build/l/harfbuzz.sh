#! /bin/bash

PRGNAME="harfbuzz"

### HarfBuzz (OpenType text shaping engine)
# HarfBuzz (свободная транслитерация персидского harf-baz, что означает "open
# type") - движок формирования текста OpenType

# Required:    no
# Recommended: glib
#              graphite2 (нужен для сборки texlive или libreoffice с системным harfbuzz)
#              icu
#              freetype
# Optional:    cairo (для сборки утилиты 'hb-view')
#              gobject-introspection
#              gtk-doc
#              fonttools (python2 и python3 модули для тестов) https://pypi.org/project/fonttools/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

GLIB="no"
GRAPHITE2="no"
ICU="no"
FREETYPE="no"
CAIRO="no"
INTROSPECTION="no"
GTK_DOC="--disable-gtk-doc"

command -v gio             &>/dev/null && GLIB="yes"
command -v gr2fonttest     &>/dev/null && GRAPHITE2="yes"
command -v icuinfo         &>/dev/null && ICU="yes"
command -v freetype-config &>/dev/null && FREETYPE="yes"
command -v cairo-sphinx    &>/dev/null && CAIRO="yes"
command -v g-ir-compiler   &>/dev/null && INTROSPECTION="yes"
# command -v gtkdoc-check    &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure                         \
    --prefix=/usr                   \
    "${GTK_DOC}"                    \
    --with-gobject="${GLIB}"        \
    --with-glib="${GLIB}"           \
    --with-graphite2="${GRAPHITE2}" \
    --with-icu="${ICU}"             \
    --with-freetype="${FREETYPE}"   \
    --with-cairo=${CAIRO}           \
    --enable-introspection="${INTROSPECTION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# переместим gtk-doc документацию в /usr/share/doc
mv "${TMP_DIR}/usr/share/gtk-doc/html/harfbuzz" "${TMP_DIR}${DOCS}/gtk-doc-html"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (OpenType text shaping engine)
#
# HarfBuzz is an OpenType text shaping engine.
#
# Home page: https://www.freedesktop.org/wiki/Software/HarfBuzz/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
