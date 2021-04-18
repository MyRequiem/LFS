#! /bin/bash

PRGNAME="harfbuzz"

### HarfBuzz (OpenType text shaping engine)
# HarfBuzz (свободная транслитерация персидского harf-baz, что означает "open
# type") - движок формирования текста OpenType

# Required:    no
# Recommended: gobject-introspection (требуется для сборки GNOME)
#              glib
#              graphite2 (нужен для сборки texlive или libreoffice с системным harfbuzz)
#              icu
#              freetype
# Optional:    cairo (для сборки утилиты 'hb-view')
#              git
#              gtk-doc
#              fonttools (python2 и python3 модули для тестов) https://pypi.org/project/fonttools/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GRAPHITE2="disabled"
GTK_DOC="disabled"

command -v gr2fonttest  &>/dev/null && GRAPHITE2="enabled"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="enabled"

mkdir build
cd build || exit 1

meson                         \
    --prefix=/usr             \
    -Dgraphite="${GRAPHITE2}" \
    -Dtests=disabled          \
    -Ddocs="${GTK_DOC}"       \
    -Dbenchmark=disabled || exit 1

ninja || exit 1

# для тестов убираем параметр -Dtests из конфигурации meson
# ninja test

DESTDIR="${TMP_DIR}" ninja install

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
