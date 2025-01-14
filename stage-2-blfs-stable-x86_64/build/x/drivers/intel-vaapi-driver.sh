#! /bin/bash

PRGNAME="intel-vaapi-driver"

### intel-vaapi-driver (VA driver for Intel G45 & HD Graphics family)
# реализация VA-API для чипсетов Intel G45 и Intel HD Graphics
# (семейство Intel Core)

# Required:    libva
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_DRM=y|m
#    CONFIG_DRM_I915=y|m

ROOT="/root/src/lfs"
source "$ROOT/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

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
# Package: ${PRGNAME} (VA driver for Intel G45 & HD Graphics family)
#
# intel-vaapi-driver is the VA-API implementation for Intel G45 chipsets and
# Intel HD Graphics for Intel Core processor family
#
# Home page: https://01.org/linuxmedia/vaapi
# Download:  https://github.com/intel/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
