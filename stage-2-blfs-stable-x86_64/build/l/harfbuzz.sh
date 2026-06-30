#! /bin/bash

PRGNAME="harfbuzz"

### HarfBuzz (OpenType text shaping engine)
# Важнейшая библиотека для формирования текста OpenType. Она соединяет
# отдельные буквы в красивые слоги и лигатуры, что критично для многих мировых
# языков.

# Required:    no
# Recommended: freetype             (пересобрать данную зависимость после сборки harfbuzz)
#              glib
#              graphite2            (нужен для сборки texlive или libreoffice с системным harfbuzz)
#              icu
# Optional:    cairo                (для сборки утилиты 'hb-view')
#              git
#              gtk-doc
#              glew
#              mesa
#              glfw                 (https://linuxfromscratch.org/slfs/view/dev/graph/glfw.html)
#              python3-fonttools    (для тестов) https://pypi.org/project/fonttools/
#              ragel                (https://www.colm.net/open-source/ragel/)
#              wasm-micro-runtime   (https://github.com/bytecodealliance/wasm-micro-runtime)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GRAPHITE2="disabled"
command -v gr2fonttest &>/dev/null && GRAPHITE2="enabled"

mkdir build
cd build || exit 1

meson setup ..                  \
    --prefix=/usr               \
    --buildtype=release         \
    -D graphite2="${GRAPHITE2}" \
    -D docs=disabled            \
    -D tests=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (OpenType text shaping engine)
#
# HarfBuzz is an OpenType text shaping engine.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
