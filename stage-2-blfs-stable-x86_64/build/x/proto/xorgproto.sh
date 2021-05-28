#! /bin/bash

PRGNAME="xorgproto"

### xorgproto (the header files for building X Window System)
# Заголовочные файлы, необходимые для сборки X Window System

# Required:    util-macros
# Recommended: no
# Optional:    fop
#              libxslt
#              xmlto
#              asciidoc (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="${XORG_PREFIX}/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

mkdir build
cd build || exit 1

# устанавим устаревшие заголовки, необходимые для старых программ, например,
# LessTif
#    -Dlegacy=true
#
# shellcheck disable=SC2086
meson                       \
    --prefix=${XORG_PREFIX} \
    -Dlegacy=true           \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

# документация
install -vm 644 ../[^m]*.txt ../PM_spec "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the header files for building X Window System)
#
# The xorgproto package provides the header files required to build the X
# Window system, and to allow other applications to build against the installed
# X Window system.
#
# Home page: https://www.x.org
# Download:  https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2020.1.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
