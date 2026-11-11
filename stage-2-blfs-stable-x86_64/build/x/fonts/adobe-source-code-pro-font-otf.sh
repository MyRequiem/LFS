#! /bin/bash

PRGNAME="adobe-source-code-pro-font-otf"

### Source Code Pro (monospaced font)
# Набор высококачественных моноширинных шрифтов от компании Adobe, созданный
# специально для программистов.

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
SRC_ARCH="$(find "${SOURCES}" -type f -name "*R-vf.tar.*" | rev | \
    cut -d / -f 1 | rev)"

# Имя директории внутри архива.
ARCH_DIR_NAME="$(tar -tf "${SOURCES}/${SRC_ARCH}" 2>/dev/null | head -n 1 | \
    cut -d / -f 1)"

# Превращаем имя директории внутри архива
# (source-code-pro-2.042R-u-1.062R-i-1.026R-vf) в массив parts, разделяя по
# дефисам.
IFS='-' read -r -a parts <<< "$ARCH_DIR_NAME"

# Собираем теги по индексам массива.
VER_1="${parts[3]}-${parts[4]}" # 2.042R-u
VER_2="${parts[5]}-${parts[6]}" # 1.062R-i
VER_3="${parts[7]}-${parts[8]}" # 1.026R-vf

VERSION="${VER_1//-/_}"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${SRC_ARCH}" || exit 1
cd "source-code-pro-${VER_1}-${VER_2}-${VER_3}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp OTF/*.otf "${TMP_DIR}${INSTALL_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

### Обновим индексы установленных шрифтов.
cd "${INSTALL_DIR}" || exit 1
# Создаем индекс файлов масштабируемых шрифтов.
mkfontscale .
# Создаем индекс файлов шрифтов в каталоге.
mkfontdir .
# Создаем файлы кэша информации о шрифтах для fontconfig
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
# Download:  https://github.com/adobe-fonts/source-code-pro/archive/refs/tags/${VER_1}/${VER_2}/${VER_3}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
