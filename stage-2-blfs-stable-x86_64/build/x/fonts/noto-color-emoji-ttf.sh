#! /bin/bash

PRGNAME="noto-color-emoji-ttf"

### noto-color-emoji-ttf (Noto Emoji fonts)
# Специальный шрифт от Google, который добавляет в вашу систему поддержку ярких
# и цветных смайликов (эмодзи). С ним общение в чатах становится привычным и
# выразительным.

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_NAME="$(find "${SOURCES}" -type f -name "v*-unicode*" | rev | \
    cut -d / -f 1 | rev)"
# => v2026-09-24-unicode18_0.tar.gz

# Узнаем точное имя корневой папки внутри архива.
# noto-emoji-2026-09-24-unicode18_0
ARCH_DIR_NAME="$(tar -tf "${SOURCES}/${ARCH_NAME}" 2>/dev/null | head -n 1 | \
    cut -d/ -f1)"

# Отрезаем все слева до слова "unicode" включительно (останется: 18_0).
RAW_VER="${ARCH_DIR_NAME##*unicode}"
# Заменяем нижнее подчёркивание на точку (18_0 -> 18.0).
VERSION="${RAW_VER//_/.}"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

# Вытаскиваем строго один файл:
# noto-emoji-2026-09-24-unicode18_0/2D/fonts/NotoColorEmoji.ttf
TTF="NotoColorEmoji.ttf"
tar -xvf "${SOURCES}/${ARCH_NAME}" --strip-components=3 \
    "${ARCH_DIR_NAME}/2D/fonts/${TTF}" || exit 1

mv "${TTF}" "${TMP_DIR}${INSTALL_DIR}"
chown root:root "${TMP_DIR}${INSTALL_DIR}/${TTF}"
chmod 644 "${TMP_DIR}${INSTALL_DIR}/${TTF}"

/bin/cp -vpR "${TMP_DIR}"/* /

# Обновим индексы установленных шрифтов.
cd "${INSTALL_DIR}" || exit 1
# Создаем индекс файлов масштабируемых шрифтов.
mkfontscale .
# Создаем индекс файлов шрифтов в каталоге.
mkfontdir .
# Создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cp fonts.dir fonts.scale "${TMP_DIR}${INSTALL_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Noto Emoji fonts)
#
# Color Noto emoji fonts, and tools for working with them.
#
# Home page: https://www.google.com/get/noto/help/emoji/
# Download:  https://github.com/googlefonts/noto-emoji/archive/refs/tags/v2026-09-24-unicode18_0.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
