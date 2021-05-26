#! /bin/bash

PRGNAME="noto-fonts-ttf"
ARCH_NAME_1="NotoSans-hinted"
ARCH_NAME_2="NotoSansSymbols-hinted"
ARCH_NAME_3="NotoSansSymbols2-unhinted"

### Noto fonts (Googles Noto fonts)
# TTF шрифты от Google (NotoSans, NotoSansSymbols и NotoSansSymbols2)

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
VERSION="$(unzip -p "${SOURCES}/${ARCH_NAME_3}.zip" | \
    grep --binary-files=text "Built on" | awk  '{ print $3 }' | tr -d -)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

for ARCH_NAME in "${ARCH_NAME_1}" "${ARCH_NAME_2}" "${ARCH_NAME_3}"; do
    unzip -nd "${PRGNAME}-${VERSION}" "${SOURCES}/${ARCH_NAME}.zip"
done

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
mkdir -pv "${TMP_DIR}${TTF_FONT_DIR}"

cp "${PRGNAME}-${VERSION}"/*.ttf "${TMP_DIR}${TTF_FONT_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индексы установленных шрифтов
cd "${TTF_FONT_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Googles Noto fonts)
#
# Noto's goal is to provide a beautiful reading experience for all languages.
# It is a free, professionally-designed, open-source collection of fonts with a
# harmonious look and feel in multiple weights and styles. Noto fonts are
# published under the SIL Open Font License (OFL) v1.1. which allows you to
# copy, modify, and redistribute them if you need. Currently, Noto covers all
# major languages of the world and many others, including European, African,
# Middle Eastern, Indic, South and Southeast Asian, Central Asian, American,
# and East Asian languages. Several minority and historical languages are also
# supported.
#
# Home page: https://www.google.com/get/noto/
#            https://github.com/googlei18n/noto-fonts
# Download:  https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_1}.zip
#            https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_2}.zip
#            https://noto-website-2.storage.googleapis.com/pkgs/${ARCH_NAME_3}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
