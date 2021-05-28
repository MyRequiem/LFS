#! /bin/bash

PRGNAME="xcb-util-image"

### xcb-util-image (port of Xlib's XImage and XShmImage functions)
# Пакет предоставляет дополнительные расширения для библиотеки XCB (X protocol
# C-language Binding)

# Required:    xcb-util
# Recommended: no
# Optional:    doxygen (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} || exit 1

make || exit 1
# LD_LIBRARY_PATH="${XORG_PREFIX}/lib" make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (port of Xlib's XImage and XShmImage functions)
#
# The xcb-util-image package provides additional extensions to the XCB library.
#
# Home page: https://xcb.freedesktop.org/
# Download:  https://xcb.freedesktop.org/dist/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
