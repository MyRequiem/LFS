#! /bin/bash

PRGNAME="xcb-util"

### xcb-util (utility libraries for X protocol C-language Binding)
# Основной набор вспомогательных модулей, которые делают работу с библиотекой
# XCB более удобной и понятной для разработчиков. Он заменяет сложные
# низкоуровневые команды на простые функции для создания графических элементов
# интерфейса. Многие модули из этого набора ранее присутствовали в Xlib, но на
# данный момент не являются частью основного протокола X.

# Required:    libxcb
# Recommended: no
# Optional:    doxygen    (для создания документации)

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utility libraries for X protocol C-language Binding)
#
# The xcb-util package provides additional extensions to the XCB library, many
# that were previously found in Xlib, but are not part of core X protocol.
#
# Home page: https://xcb.freedesktop.org/XcbUtil/
# Download:  https://xcb.freedesktop.org/dist/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
