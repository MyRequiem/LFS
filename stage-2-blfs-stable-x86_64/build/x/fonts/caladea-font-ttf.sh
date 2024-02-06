#! /bin/bash

PRGNAME="caladea-font-ttf"
ARCH_NAME="crosextrafonts"

### Caladea (Googles Caladea font)
# TTF Шрифт от Google

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp ./*.ttf "${TMP_DIR}${INSTALL_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индексы установленных шрифтов
cd "${INSTALL_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cp fonts.dir fonts.scale "${TMP_DIR}${INSTALL_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Googles Caladea font)
#
# Caladea (created as a Chrome OS extra font, hence the 'crosextrafonts'
# tarball name) is metrically compatible with MS Cambria and can be used if you
# have to edit a document which somebody started in Microsoft Office using
# Cambria and then return it to them.
#
# Home page: https://fonts.google.com/specimen/Caladea
# Download:  https://gsdview.appspot.com/chromeos-localmirror/distfiles/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
