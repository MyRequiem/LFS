#! /bin/bash

PRGNAME="dejavu-fonts-ttf"

### dejavu-fonts-ttf (DejaVu fonts)
# Семейство шрифтов, основанное на шрифтах Bitstream Vera

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}"{"${INSTALL_DIR}",/etc/fonts/conf.{d,avail}}

cp ttf/*.ttf "${TMP_DIR}${INSTALL_DIR}"

cd fontconfig || exit 1
for CONF in *; do
    cp "${CONF}" "${TMP_DIR}/etc/fonts/conf.avail/"
    (
        cd "${TMP_DIR}/etc/fonts/conf.d/" || exit 1
        ln -sf "../conf.avail/${CONF}" "${CONF}"
    )
done

chown root:root "${TMP_DIR}/etc/fonts/conf.avail"/*
chmod 644       "${TMP_DIR}/etc/fonts/conf.avail"/*

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
# Package: ${PRGNAME} (DejaVu fonts)
#
# The DejaVu fonts are a font family based on the Bitstream Vera Fonts. Its
# purpose is to provide a wider range of characters while maintaining the
# original look and feel.
#
# Home page: https://sourceforge.net/projects/dejavu/
# Download:  https://sourceforge.net/projects/dejavu/files/dejavu/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
