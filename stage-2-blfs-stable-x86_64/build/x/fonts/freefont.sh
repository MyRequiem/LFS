#! /bin/bash

PRGNAME="freefont"

### GNU FreeFont (free family of scalable outline fonts)
# Семейство масштабируемых контурных шрифтов, подходящих для общего
# использования и совместимые со всеми современными операционными системами.

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-otf-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

unzip -d ttf "${SOURCES}/${PRGNAME}-ttf-${VERSION}"*.zip

mkdir -p otf
tar -C otf -xvf "${SOURCES}/${PRGNAME}-otf-${VERSION}"*.tar.?z* || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp "ttf/${PRGNAME}-${VERSION}"/*.ttf "${TMP_DIR}${INSTALL_DIR}"
cp "otf/${PRGNAME}-${VERSION}"/*.otf "${TMP_DIR}${INSTALL_DIR}"

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
# Package: ${PRGNAME} (free family of scalable outline fonts)
#
# GNU FreeFont is a free family of scalable outline fonts, suitable for general
# use on computers and for desktop publishing. It is Unicode-encoded for
# compatibility with all modern operating systems. Besides a full set of
# characters for writing systems based on the Latin alphabet, FreeFont contains
# symbol characters and characters from other writing systems.
#
# Home page: https://www.gnu.org/software/freefont/
# Download:  https://mirror.tochlab.net/pub/gnu/freefont/${PRGNAME}-ttf-${VERSION}.zip
#            https://mirror.tochlab.net/pub/gnu/freefont/${PRGNAME}-otf-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
