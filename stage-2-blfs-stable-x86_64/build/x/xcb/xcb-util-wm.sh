#! /bin/bash

PRGNAME="xcb-util-wm"

### xcb-util-wm (XCB libraries for EWMH and ICCCM)
# Библиотеки XCB ewmh и iccm, которые включают клиент и вспомогательные функции
# для стандартов EWMH (Extended Window Manager Hints) и ICCCM (Inter-Client
# Communication Conventions Manual)

# Required:    xcb-util
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

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XCB libraries for EWMH and ICCCM)
#
# xcb-util-wm provides the XCB ewmh and iccm libraries, which include client
# and window manager helpers for EWMH and ICCCM.
#
# Home page: https://xcb.freedesktop.org/
# Download:  https://xcb.freedesktop.org/dist/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
