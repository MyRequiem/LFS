#! /bin/bash

PRGNAME="noto-cjk-fonts-ttf"

### Noto Sans CJK (Googles Noto CJK fonts)
# TTF шрифты от Google

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}"{"${INSTALL_DIR}",/etc/fonts/conf.{d,avail}}

cp fonts/*.ttc "${TMP_DIR}${INSTALL_DIR}"

NOTO_CJK_CONF="/etc/fonts/conf.avail/70-noto-cjk.conf"
cp -a "${SOURCES}/70-noto-cjk.conf" "${TMP_DIR}/etc/fonts/conf.avail/"
chown root:root "${TMP_DIR}${NOTO_CJK_CONF}"
chmod 644       "${TMP_DIR}${NOTO_CJK_CONF}"

(
    cd "${TMP_DIR}/etc/fonts/conf.d" || exit 1
    ln -svf ../conf.avail/70-noto-cjk.conf 70-noto-cjk.conf
)

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
# Package: ${PRGNAME} (Googles Noto CJK fonts)
#
# Noto Sans CJK comprehensively cover Japanese, Korean, Simplified Chinese and
# Traditional Chinese in a unified font family
#
# Home page: https://github.com/googlefonts/noto-cjk/
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
