#! /bin/bash

PRGNAME="noto-sans-cjk-fonts-otf"
ARCH_NAME_1="NotoSansCJKjp-hinted"
ARCH_NAME_2="NotoSansCJKkr-hinted"
ARCH_NAME_3="NotoSansCJKsc-hinted"
ARCH_NAME_4="NotoSansCJKtc-hinted"

### Noto Sans CJK (Googles Noto CJK fonts)
# OTF шрифты от Google (CJK: Chinese, Japanese, Korean)
# Japanese
#    * NotoSansCJKjp-Regular
#    * NotoSansMonoCJKjp-Regular
# Korean
#    * NotoSansCJKkr-Regular
#    * NotoSansMonoCJKkr-Regular
# Simplified Chinese
#    * NotoSansCJKsc-Regular
#    * NotoSansMonoCJKsc-Regular
# Traditional Chines
#    * NotoSansCJKtc-Regular
#    * NotoSansMonoCJKtc-Regular

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
# в каждом архиве лежит файл README, из которого берем версию (выводим
# содержимое архива в stdout и грепим)
#    Built on 2017-10-24 from the following noto repository:
VERSION="$(unzip -p "${SOURCES}/${ARCH_NAME_1}.zip" | \
    grep --binary-files=text "Built on" | awk  '{ print $3 }' | tr -d -)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

for ARCH_NAME in "${ARCH_NAME_1}" "${ARCH_NAME_2}" \
        "${ARCH_NAME_3}" "${ARCH_NAME_4}"; do
    unzip -nd "${PRGNAME}-${VERSION}" "${SOURCES}/${ARCH_NAME}.zip"
done

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
OTF_FONT_DIR="/usr/share/fonts/X11/OTF/"
mkdir -pv "${TMP_DIR}${OTF_FONT_DIR}"

find "${PRGNAME}-${VERSION}" -type f -name "*-Regular.otf" \
    -exec cp {} "${TMP_DIR}${OTF_FONT_DIR}" \;

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
# Package: ${PRGNAME} (Googles Noto CJK fonts)
#
# Noto Sans CJK comprehensively cover Japanese, Korean, Simplified Chinese and
# Traditional Chinese in a unified font family:
# Japanese
#    * NotoSansCJKjp-Regular
#    * NotoSansMonoCJKjp-Regular
# Korean
#    * NotoSansCJKkr-Regular
#    * NotoSansMonoCJKkr-Regular
# Simplified Chinese
#    * NotoSansCJKsc-Regular
#    * NotoSansMonoCJKsc-Regular
# Traditional Chines
#    * NotoSansCJKtc-Regular
#    * NotoSansMonoCJKtc-Regular
#
# Home page: https://www.google.com/get/noto/
#            https://github.com/googlei18n/noto-fonts
#            https://www.google.com/get/noto/help/cjk/
# Download:  https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_1}.zip
#            https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_2}.zip
#            https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_3}.zip
#            https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_4}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
