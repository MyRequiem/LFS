#! /bin/bash

PRGNAME="adobe-source-code-pro-font-otf"

### Source Code Pro (monospaced font)
# Набор моноширинных шрифтов, которые были разработаны для удобной работы в
# среде программирования. Это семейство шрифтов является дополнительным к
# семейству Source Sans

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_NAME="$(find "${SOURCES}" -type f -name "*R-vf.tar.*" | rev | \
    cut -d / -f 1 | rev)"
VERSION=$(echo ${ARCH_NAME} | cut -d R -f 1)

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}" || exit 1
cd "source-code-pro-"* || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp OTF/*.otf "${TMP_DIR}${INSTALL_DIR}"

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
# Package: ${PRGNAME} (monospaced font)
#
# Source Code Pro is a set of monospaced OpenType fonts that have been designed
# to work well in coding environments. This family of fonts is a complementary
# design to the Source Sans family.
#
# Home page: https://github.com/adobe-fonts/source-code-pro/
# Download:  https://github.com/adobe-fonts/source-code-pro/archive/refs/tags/2.042R-u/1.062R-i/${VERSION}R-vf.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
