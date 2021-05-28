#! /bin/bash

PRGNAME="cantarell-font-otf"
ARCH_NAME="cantarell-fonts"

### Cantarell fonts (The Cantarell typeface family)
# Шрифт поставляемый по умолчанию с интерфейсом GNOME, который заменил шрифты
# Bitstream Vera и DejaVu

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
OTF_FONT_DIR="/usr/share/fonts/X11/OTF"
mkdir -pv "${TMP_DIR}${OTF_FONT_DIR}"

mkdir -p build
cd build || exit 1

meson                            \
    --prefix=/usr                \
    -Duseprebuilt=true           \
    -Dbuildappstream=false       \
    -Dfontsdir="${OTF_FONT_DIR}" \
    .. || exit 1

DESTDIR="${TMP_DIR}" ninja install

/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индексы установленных шрифтов
cd "${OTF_FONT_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Cantarell typeface family)
#
# Cantarell is the default typeface supplied with the user interface of GNOME
# since version 3.0, replacing Bitstream Vera and DejaVu
#
# Home page: https://gitlab.gnome.org/GNOME/${ARCH_NAME}/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
