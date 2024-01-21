#! /bin/bash

PRGNAME="xbitmaps"

### xbitmaps (miscellaneous X bitmap files)
# Пакет содержит растровые изображения, используемые X-приложениями

# Required:    util-macros
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (miscellaneous X bitmap files)
#
# The xbitmaps package contains bitmap images used by multiple applications
# built in Xorg chapter.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/data/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
