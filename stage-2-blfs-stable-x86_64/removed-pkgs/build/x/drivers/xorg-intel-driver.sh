#! /bin/bash

PRGNAME="xorg-intel-driver"
ARCH_NAME="xf86-video-intel"

### Xorg Intel Driver (X.org graphics driver for Intel graphics)
# Видео драйвер X.Org для встроенных видеочипов Intel, включая 8xx, 9xx, Gxx,
# Qxx, HD, Iris и Iris Pro графические процессоры.

# Required:    xcb-util
#              xorg-server
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_DRM=y
#    CONFIG_DRM_I915=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./autogen.sh          \
    ${XORG_CONFIG}    \
    --enable-kms-only \
    --enable-uxa      \
    --mandir=/usr/share/man || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

mv -v /usr/share/man/man4/intel-virtual-output.4 \
    /usr/share/man/man1/intel-virtual-output.1
sed -i '/\.TH/s/4/1/' /usr/share/man/man1/intel-virtual-output.1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (X.org graphics driver for Intel graphics)
#
# The Xorg Intel Driver package contains the X.Org Video Driver for Intel
# integrated video chips including 8xx, 9xx, Gxx, Qxx, HD, Iris, and Iris Pro
# graphics processors.
#
# Home page: https://cgit.freedesktop.org/xorg/driver/${ARCH_NAME}
# Download:  https://anduin.linuxfromscratch.org/BLFS/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
