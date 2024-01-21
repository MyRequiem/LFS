#! /bin/bash

PRGNAME="xcb-util-renderutil"

### xcb-util-renderutil (XCB renderutil library)
# Библиотека (дополнительное расширение XCB), которая включает некоторые
# удобные функции для рендеринга.

# Required:    libxcb
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
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XCB renderutil library)
#
# xcb-util-renderutil provides the XCB renderutil library (additional
# extensions to the XCB), which includes some convenience functions for the
# Render extension.
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
