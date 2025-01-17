#! /bin/bash

PRGNAME="xorg-fbdev-driver"
ARCH_NAME="xf86-video-fbdev"

### Xorg Fbdev Driver (X.Org generic framebuffer video driver)
# Общий видеодрайвер X.Org для устройств работающих с фреймбуфером. Этот
# драйвер часто используется как резервный драйвер, если специфичные для
# оборудования и драйверы VESA не загружаются или отсутствуют. Если этот
# драйвер не установлен, Xorg Server выведет предупреждение при запуске, но его
# можно спокойно игнорировать, если драйвер для конкретного оборудования
# работает нормально.

# Required:    xorg-server
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

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
# Package: ${PRGNAME} (X.Org generic framebuffer video driver)
#
# The Xorg Fbdev Driver package contains the generic X.Org Video Driver for
# framebuffer devices. This driver is often used as fallback driver if the
# hardware specific and VESA drivers fail to load or are not present. If this
# driver is not installed, Xorg Server will print a warning on startup, but it
# can be safely ignored if hardware specific driver works well.
#
# Home page: https://cgit.freedesktop.org/xorg/driver/${ARCH_NAME}
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
