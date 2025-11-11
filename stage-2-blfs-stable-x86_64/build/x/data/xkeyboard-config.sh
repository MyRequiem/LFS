#! /bin/bash

PRGNAME="xkeyboard-config"

### XKeyboardConfig (X Keyboard Extension config files)
# База данных конфигурации клавиатуры для X

# Required:    xorg-libraries
# Recommended: no
# Optional:    --- для тестов ---
#              libxkbcommon
#              python3-pytest
#              xorg-applications

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                   \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X Keyboard Extension config files and)
#
# The XKeyboardConfig package contains the keyboard configuration database for
# the X Window System
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/data/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
