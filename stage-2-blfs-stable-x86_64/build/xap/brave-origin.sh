#!/bin/bash

PRGNAME="brave-origin"

### Brave Origin (Official Minimalist chromium-based Brave Browser)
# Легковесная сборка известного браузера Brave Browser на основе движка
# Chromium, созданная компанией Brave Software как официальный премиум-продукт
# для большей приватности и экономии системных ресурсов. По сути это тот же
# Brave, но максимально урезанный. Из оригинального браузера полностью удалены
# все коммерческие инструменты, встроенную рекламу и сервисы, которые многие
# пользователи считали лишними («раздутый софт» или bloatware). Удалены:
#     - Криптовалюта и кошелек.
#     - Реклама и спонсорский контент.
#     - Сервисы подписок.
#     - Встроенный VPN-сервис.
#     - Сервис видеозвонков Brave Talk.
#     - Лишние виджеты (новостная лента Brave News).
#     - Телеметрия. (модули сбора статистики и отправки отчетов разработчикам).

# Required:    nss
#              libcups или cups
# Recommended: no
# Optional:    qt5-components
#              qt6

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"

# Официальный, легковесный текстовый API-сервис версий, предназначенный именно
# для системных апдейтеров:
BRAVE_API="https://versions.brave.com"
VERSION=$(curl -s "${BRAVE_API}/latest/release-linux-x64.version")

if [ -z "${VERSION}" ] || echo "${VERSION}" | grep -qi "Error"; then
    echo "Error: Failed to fetch the latest version from update server."
    exit 1
fi

INSTALLED_VER=$(find /var/log/packages/ -type f -name "${PRGNAME}-*" | \
    rev |  cut -f 1 -d - | rev)
echo -en "Installed version: ${INSTALLED_VER}\nLatest version:    "
echo "${VERSION}"

echo -ne "\nContinue? [y/N]: "
read -r YESNO
[ "${YESNO}" != "y" ] && {
    exit 0
}

DEB_PACKAGE="${PRGNAME}_${VERSION}_amd64.deb"
rm -f "${SOURCES}/${PRGNAME}_"*

# Качаем актуальный стабильный релиз .deb с GitHub.
GIT_HOME_PAGE="https://github.com/brave/brave-browser"
DOWNLOAD_PATH="${GIT_HOME_PAGE}/releases/download/v${VERSION}/${DEB_PACKAGE}"
wget -P "${SOURCES}" "${DOWNLOAD_PATH}" || {
    echo "Download ${DOWNLOAD_PATH}" error!
    exit 1
}

# Удаляем установленную версию.
[ -n "${INSTALLED_VER}" ] && \
    yes | removepkg --backup "/var/log/packages/${PRGNAME}-${INSTALLED_VER}"

TMP_DIR="/tmp/package-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}/usr/share/pixmaps"
cd "${TMP_DIR}" || exit 1

# Распаковываем архив с бинарниками из .deb пакета.
ar x "${SOURCES}/${DEB_PACKAGE}" data.tar.xz || exit 1
tar xvf data.tar.xz || exit 1
rm -f data.tar.xz

rm -rf etc
rm -rf usr/share/{doc,gnome-control-center}

mv "opt/brave.com/${PRGNAME}" opt/
rm -rf opt/brave.com

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

ln -svf "../../opt/${PRGNAME}/${PRGNAME}" "${TMP_DIR}/usr/bin/${PRGNAME}-stable"

# распакуем man-страницу
gunzip "${TMP_DIR}/usr/share/man/man1/${PRGNAME}-stable.1.gz"
rm -f "${TMP_DIR}/usr/share/man/man1/${PRGNAME}.1.gz"

cp "${TMP_DIR}/opt/${PRGNAME}/product_logo_128.png" \
    "${TMP_DIR}/usr/share/pixmaps/${PRGNAME}.png"

rm -f "${TMP_DIR}/usr/share/applications/com.brave.Origin.desktop"

cat << EOF > "${TMP_DIR}/usr/share/applications/${PRGNAME}.desktop"
[Desktop Entry]
Version=1.0
Name=Brave Origin
GenericName=Web Browser
Comment=Access the Internet with maximum privacy
Exec=${PRGNAME} %U
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=${PRGNAME}
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Official Minimalist chromium-based Brave Browser)
#
# Brave Origin is an official, minimalist version of Brave Browser built by
# Brave Software. It is tailored for users who want core privacy and Shields
# ad-blocking without revenue features. It is distributed as a paid upgrade on
# Windows/macOS and free for Linux users.
#
# Disabled or removed components:
#    - AI Assistant (Leo), Brave Rewards, and BAT token tools.
#    - Brave Wallet, Web3 domains, Crypto configurations and crypto tools.
#    - Built-in VPN, telemetry, Brave Talk, Brave News, and Playlist.
#    - Sponsored background images and commercial home widgets.
#
# Home page: https://brave.com/origin/
# Download:  ${DOWNLOAD_PATH}
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
