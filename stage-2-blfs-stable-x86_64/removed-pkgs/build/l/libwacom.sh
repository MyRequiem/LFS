#! /bin/bash

PRGNAME="libwacom"

### libwacom (Wacom tablet library)
# Библиотека, которая предоставляет приложениям информацию о подключенных
# графических планшетах Wacom и других производителей, позволяя им
# идентифицировать конкретную модель и ее характеристики. Используется
# клиентскими программами, чтобы получать данные о планшете, такие как его тип
# (например, наэкранный), размер, и предоставлять пользователю соответствующие
# настройки и опции.

# Required:    libevdev
#              libgudev
# Recommended: libxml2
# Optional:    doxygen
#              git
#              librsvg
#              valgrind
#              --- для тестов ---
#              python3-pytest
#              python3-libevdev     (https://pypi.org/project/libevdev/)
#              python3-pyudev       (https://pypi.org/project/pyudev/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D tests=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

# если обновляем пакет, удалим старую версию базы данных устройств
rm -rf /usr/share/libwacom

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Wacom tablet library)
#
# The libwacom package contains a library used to identify graphics tablets
# from Wacom or various other vendors and their model-specific features
#
# Home page: https://github.com/linuxwacom/${PRGNAME}/
# Download:  https://github.com/linuxwacom/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
